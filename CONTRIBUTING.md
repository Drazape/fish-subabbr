Contribution to the primary codebase doesn't have any special instructions. This is a guide on contributing packages.

# General Guidance
## Official Repository compatibility
To be compatible with the official repository helper, each package (a function) must do a job depending on the distribution of the package to be able to be enabled with `sub-abbrs` — the package repository helper/pkg-enabler. It is safer to meet both the requirements.

- **Static** [^static-func]: The function runs on runs on the [events](https://fishshell.com/docs/4.6/language.html#event-handlers "automatically run when a specific event takes place"): `sub-abbr{s,_<commands>}`
- **Dynamic** [^dynamic-func]: The function name must have the format `_sub-abbr_<id>`, where `id` is what is used is given as an argument to `sub-abbrs`
## Multi-*Base Command* support
Packages should always use the *RegExp* [switch](./README.md#Switches) so that users can create Sub-Command Abbreviations with multiple *Base Commands* easily, without having to parse RegExp themselves. [^regex-workaround]

# Distribution
## Package Types
|  ~  | Official Repository | 3rd-party |
| :-: | :-----------------: | --------- |
| **Distribution** | Via base package | Yourself. Users will have to install the package before using it. |
| **Configuration** | ❌ | Optional |
| **Updates** | Delayed for review | Direct |
| **Suffix** [^func-suffix] | Prohibited | Required |

## Official Repository
Each package is a single function in the repository provides abbreviations for the specific command it corresponds to.
> [!TIP]
> Have a look at other packages defined in the repository before pushing your own here.
## 3rd-party
3rd-party packages/repositories can use the program however they want. For example:
- Simple packages can directly distribute the abbreviations into shell initialization configuration. This way they don't need to be enabled after they have been installed (it was installed for the purpose of using it afterall)
- Complex packages can ship their own commands and front-ends to configure the abbreviations and provide other features
- Packages may or may not choose to maintain compatibility with the official repository helper: `sub-abbrs`.
You might be able to get some creative inspiration by exploring existing packages/repositories, or you could also choose to an unofficial repository if it suits your project better. 

[^func-suffix]: Each official repository compatible package is simply a function. The functions outside the official repository must have a unique suffix to avoid conflicts, while the official repository packages are prohibited to have one.
	- **Official**: `_sub-abbr_<command>`
	- **3rd-party**:
		- **Single-Command**: `_sub-abbr_<command>_<pkgname/purpose>`
		- **Multi-Command**: `_sub-abbr_<pkgname/purpose>`
[^regex-workaround]: You can not have more than abbreviation for the same *Sub-Command* without using the *RegExp* switch. This is because `abbr` sets the identity of the internal abbreviation as to that of the *Sub-Command* that is expanded, and there can only be one identity each for every abbreviation, and any attempt to create any more will result in overwriting of the older one. But since the *RegExp* flag allows us to have custom identities for the abbreviations, we can exploit it with the *Function* switch to create as many abbreviations for the same *Sub-Command* as we want. ([relevant Fish discussion](https://github.com/fish-shell/fish-shell/discussions/11682))

[^static-func]: A function is distributed as statically distributed if it is part of the shell initialization configuratino. Functions distributed as such are automatically loaded on the shell start-up; i.e. can be listed with `functions`. ([documentation](https://fishshell.com/docs/4.7/tutorial.html#startup-where-s-bashrc))
[^dynamic-func]: A function is dynamically distributed if it is distributed as a file in one of `$fish_function_path`; The file is sourced the first time the function is called. ([documentation](https://fishshell.com/docs/4.7/tutorial.html#autoloading-functions))
