#! /bin/sh
set -xve
dotnet restore
dotnet pack -c Release -o /src/packages
dotnet publish -c Release -o /src/publish/dotnet-toolbox
apt-get update
apt-get -y install zip
cd /src/publish/dotnet-toolbox
zip -r /src/publish/dotnet-toolbox.zip *
tar -cvzf /src/publish/dotnet-toolbox.tar.gz *
apt-get -y install jq
release=$(curl https://api.github.com/repos/wli3/dotnettoolbox/releases/latest)
asset_ids=$(echo $release | jq '.assets | .[] | .id')
for id in $asset_ids
do
  curl -X DELETE https://api.github.com/repos/wli3/dotnettoolbox/releases/assets/$id -u $GitHubToken:
done
release_id=$(echo $release | jq .id)
cd /src/publish
curl -X POST -H 'Content-Type:application/zip' --data-binary @dotnet-toolbox.zip https://uploads.github.com/repos/wli3/dotnettoolbox/releases/$release_id/assets?name=dotnet-toolbox.zip -u $GitHubToken:
curl -X POST -H 'Content-Type:application/zip' --data-binary @dotnet-toolbox.tar.gz https://uploads.github.com/repos/wli3/dotnettoolbox/releases/$release_id/assets?name=dotnet-toolbox.tar.gz -u $GitHubToken:
