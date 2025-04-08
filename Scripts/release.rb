#!/usr/bin/ruby

require 'json'
require 'Open3'
require 'fileutils'
require_relative 'version'

def usage
  puts "usage: release.rb CMD NEWVER RELTITLE RELNOTES FILES..."
end

def ex(e)
  puts e; out, err, status = Open3.capture3 e
  unless status.success?
    warn "failure: out=#{out}, err=#{err}, status=#{status}"
    exit 1
  end
  out
end

%w(git gh pod swift).each do |cmd|
  print "checking for #{cmd}... "
  cmd_path = %x(command -v #{cmd})
  unless $?.success? then
    puts 'no'
    warn "Abort: #{cmd} not found"
    exit 1
  end
  puts 'yes'
end

pod_sessions = %x(pod trunk me --silent)
unless $?.success? then
  warn "Abort: Missing CocoaPods session"
  puts pod_sessions
  puts "\nSee https://guides.cocoapods.org/making/getting-setup-with-trunk.html"
  exit 1
end

puts "ARGV=#{ARGV}"

CMD = ARGV.shift
if !CMD then usage; exit 1 end

NEW_VERSION = ARGV.shift
if !NEW_VERSION then usage; exit 1 end

RELTITLE = ARGV.shift
if !RELTITLE then usage; exit 1 end

RELNOTES = ARGV.shift
if !RELNOTES then usage; exit 1 end

DRAFT = CMD != 'publish'
PRERELEASE = !!EXTRA_INFO # true if the version has extra info -Beta1,
                          # -RC1, etc.

COMMITTED = 'Release/committed'
VERFILE = "Release/#{NEW_VERSION}"
PUBLISHED = 'Release/published'
TAG = VER

FILES = ARGV.join ' '

puts "#{CMD.capitalize}ing #{VER_ALL}"
puts "DRAFT=#{DRAFT}, PRERELEASE=#{PRERELEASE}, TAG=#{TAG}, FILES=#{FILES}"

unless REPO_STATE.empty? then
  warn "Abort: Attempt to release from #{REPO_STATE} repo"
  exit 1
end

# get last release from github
RELEASES = JSON.parse(%x(gh release list -O desc -L 1 --json tagName))
if RELEASES.count == 0 then
  LAST_VERSION = nil
  puts 'No previous releases'
else
  LAST_RELEASE = RELEASES[0]
  LAST_VERSION = LAST_RELEASE['tagName']
  puts "LAST_VERSION=#{LAST_VERSION}"
end

if CMD == 'commit' then
  SWIFTPM_FILES = FILES.split
  SWIFTPM_FILES.each do |f|
    if f.match? /-signed/ then
      SIGNED_CHECKSUM = %x(swift package compute-checksum #{f}).strip
      puts "#{f}: #{SIGNED_CHECKSUM}"
    elsif f.match? /-unsigned/ then
      UNSIGNED_CHECKSUM = %x(swift package compute-checksum #{f}).strip
      puts "#{f}: #{UNSIGNED_CHECKSUM}"
    end
  end

  pkg = File.read 'Scripts/templates/_Package.swift'
  pkg.gsub! '__VERSION__', VER
  pkg.gsub! '__TAG__', TAG
  pkg.gsub! '__SIGNED_CHECKSUM__', SIGNED_CHECKSUM
  pkg.gsub! '__UNSIGNED_CHECKSUM__', UNSIGNED_CHECKSUM
  File.write 'Package.swift', pkg
  puts "Swift PM manifest updated: Package.swift"

  pod = File.read 'Scripts/templates/_PollingSDK.podspec'
  pod.gsub! '__VERSION__', VER
  pod.gsub! '__TAG__', TAG
  File.write 'Release/PollingSDK.podspec', pod
  puts "CocoaPods manifest updated: Release/PollingSDK.podspec"

  status = %x(git status -s).strip
  unless status == 'M Package.swift' then
    puts "Repo status:\n #{status}"
    puts "Abort: Package.swift did not change or repo is not clean"
    exit 1
  end

  ex "git add Package.swift"
  ex "git commit -m 'Release #{NEW_VERSION}'"

  FileUtils.touch COMMITTED

  exit 0
end

title = (File.exist?(RELTITLE) && File.read(RELTITLE)) || NEW_VERSION
notes = (File.exist?(RELNOTES) && File.read(RELNOTES)) || nil

if CMD == 'prepare' then
  unless File.exist? COMMITTED then
    puts "Abort: Missing #{COMMITTED}; Run `make commit-release` before preparing"
    exit 1
  end
  # check if the version was properly bumped
  if LAST_VERSION && (LAST_VERSION == TAG) then
    puts "LAST_VERSION = TAG = #{TAG}"
    puts "Abort: Release #{NEW_VERSION} already exists"
    exit 1
  end
  # get draft release notes
  if LAST_VERSION && !notes then
    notes = ""
    raw_notes = ex "git log --pretty='format:- %sGITLOGOPTNEWLINE%b' #{LAST_VERSION}..HEAD --"
    raw_notes.gsub! /GITLOGOPTNEWLINE$/, ''
    raw_notes.gsub! /GITLOGOPTNEWLINE/, "\n\n"
    raw_notes.split("\n").each do |line|
      if /^-/.match(line) then
        notes << "#{line}\n"
      elsif /^$/.match(line) then
        notes << "#{line}\n"
      else
        notes << "    #{line}\n"
      end
    end
  else
    if !notes then notes = "First release\n" end
  end
  File.write RELTITLE, title
  File.write RELNOTES, notes
  pre = (PRERELEASE && '--prerelease') || ''
  ex "gh release create #{TAG} --draft -t \"#{title.strip}\" -F #{RELNOTES} #{pre} #{FILES}"
  FileUtils.touch VERFILE
end

puts "title=#{title}"
if notes && notes.length > 72 then
  puts "notes=#{notes[0..72]}..."
else
  puts "notes=#{notes}"
end

if CMD == 'edit' then
  unless File.exist? VERFILE then
    warn "About: Missing #{VERFILE}; Run `make prepare-release` before editing"
    exit 1
  end
  pre = (PRERELEASE && '--prerelease') || ''
  ex "gh release edit #{TAG} --draft -t \"#{title.strip}\" -F #{RELNOTES} #{pre}"
end

if CMD == 'publish' then
  unless File.exist? VERFILE then
    warn "Abort: Missing #{VERFILE}; Run `make prepare-release` before publishing"
    exit 1
  end
  ex "git push"
  pre = (PRERELEASE && '--prerelease') || ''
  ex "gh release edit #{TAG} --draft=false -t \"#{title.strip}\" -F #{RELNOTES} #{pre}"
  ex "pod trunk push Release/PollingSDK.podspec"
  docs_modified = %x(git -C Docs status --porcelain).length > 0
  if $?.exitstatus == 0 && docs_modified then
    ex "git -C Docs add ."
    ex "git -C Docs commit -m 'Update docs to #{NEW_VERSION}'"
    ex "git -C Docs push origin HEAD:docs"
  end
  FileUtils.touch PUBLISHED
end

ex "gh release view #{TAG} -w"

unless CMD == 'publish' then
  puts "Inspect and edit #{RELTITLE} and #{RELNOTES} before publishing!"
end
