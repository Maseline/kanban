#!/usr/bin/env bash
# in scripts/asdf_plugins.sh 
# install necessary plugins 
plugins=(
    "github-cli"
    "packer"
    "terraform"
    "awscli"
    "elixir"
    "erlang"
    "postgres"
    "jq"
    "age"
    "sops"
)
for plugin in "${plugins[@]}"; do
    asdf plugin add "$plugin" || true
    # the || true is to prevent the script from stopping if the plugin is already installed
done
echo "Installation complete"
echo "Please restart terminal"