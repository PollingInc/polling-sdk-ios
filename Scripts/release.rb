#!/usr/bin/ruby

require 'json'

puts Dir.getwd

puts "ARGV=#{ARGV}"
if ARGV.count == 0 then
  puts "new version must be provided as an argument"
  exit 1
end

TITLE = nil
NEWVER = ARGV[0]
RELNOTES = ARGV[1]
DRAFT = true

# true if the version has extra info -Beta1, -RC1, etc.
PRERELEASE = true

# get last release from github
RELEASES = JSON.parse(%x(gh release list -O desc -L 1 --json tagName))
if RELEASES.count == 0 then
  last_version = nil
  puts 'no previous releases'
else
  last_release = RELEASES[0]
  last_version = last_release['tagName']
  puts "last version #{last_version}"
end

# get current version
new_version = ARGV[0]

if last_version != nil then
  # check if the version was properly bumped
  if last_version == new_version then
    puts "last_version = new_version = #{new_version}"
    puts "abort"
    exit 1
  else
    # get draft release notes
    notes = ""
    raw_notes = %x(git log #{last_version}.. --pretty="format:- %sGITLOGOPTNEWLINE%b")
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
  end
else
  notes = "First release\n"
end

File.write RELNOTES, notes
