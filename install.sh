#!/usr/bin/env bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

DEFAULT_VERSION=latest

show_help() {
cat << EOF
Usage: $(basename "$0") <options>

    -h, --help                              Display help
    -v, --version                           The Camel K version to use (default: $DEFAULT_VERSION)
    --github-token                          Optional token used when fetching the latest Camel K release to avoid hitting rate limits

EOF
}

main() {
    local version="$DEFAULT_VERSION"
    local github_token=
    
    parse_command_line "$@"

    install_camel_k
    cleanup_workspace
}

parse_command_line() {
    while :; do
        case "${1:-}" in
            -h|--help)
                show_help
                exit
                ;;
            -v|--version)
                if [[ -n "${2:-}" ]]; then
                    version="$2"
                    shift
                else
                    echo "ERROR: '-v|--version' cannot be empty." >&2
                    show_help
                    exit 1
                fi
                ;;
            --github-token)
                if [[ -n "${2:-}" ]]; then
                    github_token="$2"
                    shift
                else
                    echo "ERROR: '--github-token' cannot be empty." >&2
                    show_help
                    exit 1
                fi
                ;;
            *)
                break
                ;;
        esac

        shift
    done
}

install_camel_k() {
    install_version=$version
    info=
    if [[ "$version" = "latest" ]]
    then
        if [[ -z "$github_token" ]]
        then
            install_version=$(curl --silent "https://api.github.com/repos/apache/camel-k/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        else
            install_version=$(curl -H "Authorization: $github_token" --silent "https://api.github.com/repos/apache/camel-k/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        fi
        info="=$install_version"
    fi
    os=$(get_os)
    binary_version=$(echo $install_version | tr -d v)

    echo "Installing Camel K CLI version $version$info on $os..."

    curl -L --silent https://github.com/apache/camel-k/releases/download/$install_version/camel-k-client-$binary_version-$os-64bit.tar.gz -o kamel.tar.gz
    mkdir -p _kamel
    tar -zxf kamel.tar.gz --directory ./_kamel

    if [[ "$os" = "windows" ]]
    then
        mkdir /camel-k
        mv ./_kamel/kamel.exe /camel-k/
        echo "/camel-k" >> $GITHUB_PATH
    else
        sudo mv ./_kamel/kamel /usr/local/bin/
    fi

    echo "Camel K CLI installed successfully!"
}

cleanup_workspace() {
    if [[ -f "./kamel.tar.gz" ]]
    then
        rm kamel.tar.gz
    fi

    if [[ -d "./_kamel" ]]
    then
        rm -r _kamel
    fi
}

get_os() {
    osline="$(uname -s)"
    case "${osline}" in
        Linux*)     os=linux;;
        Darwin*)    os=mac;;
        CYGWIN*)    os=windows;;
        MINGW*)     os=windows;;
        Windows*)   os=windows;;
        *)          os="UNKNOWN:${osline}"
    esac
    echo ${os}
}

main "$@"
