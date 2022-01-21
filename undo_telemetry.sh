# dc.services.visualstudio.com
# vortex.data.microsoft.com
TELEMETRY_URLS="(dc\.services\.visualstudio\.com)|(vortex\.data\.microsoft\.com)|(ticino\.blob\.core\.windows\.net)|(www\.microsoft\.com)|(api\.esrp\.microsoft\.com)|(dc\.services\.visualstudio\.com)|(dc\.applicationinsights\.microsoft\.com)|(dc\.applicationinsights\.azure\.com)|(global\.in\.ai\.monitor\.azure\.com)|(global\.in\.ai\.privatelink\.monitor\.azure\.com)|(dc\.trafficmanager\.net)|(weu05-breeziest-in\.cloudapp\.net)|(experimentation\.visualstudio\.com)|(code\.visualstudio\.com)|(current\.cvd\.clamav\.net)"

TELEMETRY_URLS=${TELEMETRY_URLS}"|(img\.shields\.io)|(vsmarketplacebadge\.apphb\.com)|(img\.shields\.io)|(badge\.buildkite\.com)|(raw\.githubusercontent\.com)|(api\.codeclimate\.com)|(codeclimate\.com)"

REPLACEMENT="s/$TELEMETRY_URLS/0\.0\.0\.0/g"

#include common functions
. ../utils.sh

if [[ "$OS_NAME" == "osx" ]]; then
  if is_gnu_sed; then
    grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i -E $REPLACEMENT
  else
    grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i '' -E $REPLACEMENT
  fi
else
  grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i -E $REPLACEMENT
fi
