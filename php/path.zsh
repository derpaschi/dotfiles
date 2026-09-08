# PHP and Composer from Homebrew.
brew_prefix="${HOMEBREW_PREFIX:-/opt/homebrew}"

# icu4c: needed to build PHP extensions (e.g. intl) against Homebrew's ICU.
# Versioned keg (icu4c@NN), symlinked under opt/, hence the -/ qualifier;
# pick the newest one that is installed.
icu_kegs=("$brew_prefix"/opt/icu4c@*(N-/on))
if (( $#icu_kegs )); then
  icu="${icu_kegs[-1]}"
  export PATH="$icu/bin:$icu/sbin:$PATH"
  export LDFLAGS="-L$icu/lib"
  export CPPFLAGS="-I$icu/include"
  export PKG_CONFIG_PATH="$icu/lib/pkgconfig"
  unset icu
fi
unset icu_kegs

# PHP 8.3 (keg-only versioned formula, so it is not linked into bin/)
if [[ -d "$brew_prefix/opt/php@8.3" ]]; then
  export PATH="$brew_prefix/opt/php@8.3/bin:$brew_prefix/opt/php@8.3/sbin:$PATH"
fi

unset brew_prefix

# Composer global binaries (composer global config bin-dir)
export PATH="$HOME/.composer/vendor/bin:$PATH"
