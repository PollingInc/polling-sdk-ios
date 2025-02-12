SANDBOXED = ENV['ENABLE_USER_SCRIPT_SANDBOXING']
PRODUCT_NAME = ENV['PRODUCT_NAME']
VER = ENV['PROJECT_VERSION']
CONFIG = ENV['CONFIGURATION']

if SANDBOXED == 'YES' then
  puts "note: ENABLE_USER_SCRIPT_SANDBOXING=#{SANDBOXED} and CONFIGURATION=#{CONFIG}"
  if CONFIG == 'RELEASE' then
    puts 'error: Sandboxing not supported for Release builds'
    exit 1
  end
end

ver_components = VER.split('.')

MAJOR = ver_components[0]
MINOR = ver_components[1] || '0'
PATCH = ver_components[2] || '0'

VER_LONG = "v#{VER}"

# NOTE: git commands will fail if sandboxing is enabled
if SANDBOXED != 'YES' then
  BRANCH = %x(git branch --show-current).strip
  COMMIT = %x(git rev-parse --short HEAD).strip

  VER_LONG << ":#{BRANCH}@#{COMMIT}"
  VER_LONG << ":#{CONFIG}"

  # not `git diff --quiet` because we consider the repo dirty if it
  # contains untracked files in addition to staged or unstated changes
  REPO_IS_DIRTY = %x(git status -s).length > 0
  if REPO_IS_DIRTY then
    REPO_STATE = 'dirty'
    VER_LONG << ":#{REPO_STATE}"
  else
    REPO_STATE = ''
  end
else
  BRANCH = ''
  COMMIT = ''
  REPO_STATE = ''
  VER_LONG << ":#{CONFIG}"
end

VER_ALL = "#{PRODUCT_NAME} #{VER_LONG}"
