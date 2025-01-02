# Polling SDK for iOS

Create a `Configs/Local.xcconfig` for developer specific overrides and
configurations.

    DEVELOPMENT_TEAM = <apple-development-team-identifier>
    UNIQUE_BUNDLE_DISAMBIGUATOR = .${DEVELOPMENT_TEAM}

    GCC_PREPROCESSOR_DEFINITIONS[config=Debug] = $(inherited) USE_LOCAL_SERVER
