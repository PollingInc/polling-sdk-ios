#!/usr/bin/ruby

require 'json'
require_relative 'version'

def usage
  puts "usage: release.rb CMD NEWVER RELTITLE RELNOTES"
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

puts "#{CMD.capitalize}ing #{VER_ALL}"
puts "DRAFT=#{DRAFT}, PRERELEASE=#{PRERELEASE}"

# get last release from github
RELEASES = JSON.parse(%x(gh release list -O desc -L 1 --json tagName))
if RELEASES.count == 0 then
  LAST_VERSION = nil
  puts 'no previous releases'
else
  LAST_RELEASE = RELEASES[0]
  LAST_VERSION = LAST_RELEASE['tagName']
  puts "LAST_VERSION=#{LAST_VERSION}"
end

# check if the version was properly bumped
if LAST_VERSION && LAST_VERSION == NEW_VERSION then
  puts "LAST_VERSION = NEW_VERSION = #{NEW_VERSION}"
  puts "abort"
  exit 1
end

title = (File.exist?(RELTITLE) && File.read(RELTITLE)) || NEW_VERSION
notes = (File.exist?(RELNOTES) && File.read(RELNOTES)) || nil

if CMD == 'prepare' then
  # get draft release notes
  if LAST_VERSION && !notes then
    notes = ""
    raw_notes = %x(git log #{LAST_VERSION}.. --pretty="format:- %sGITLOGOPTNEWLINE%b")
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
end

puts "title=#{title}"
if notes && notes.length > 72 then
  puts "notes=#{notes[0..72]}..."
else
  puts "notes=#{notes}"
end

puts "Inspect/edit #{RELTITLE} and #{RELNOTES} before publishing!"
