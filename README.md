# Purpose
Simplify abbrevating subcommands [^simplification]

# Uses
## Defaults (convenience)
### Switches for certain subcommands  
```fish
sub-abbr --set-cursor 'nh os' switch{,' % --bypass-root-check'}
```
[^nh-why-allow-root]  
<img width="1415" height="82" alt="nh-switch" src="https://github.com/user-attachments/assets/394abe78-a4f7-4f82-a77e-488666010b64" />
### A combination of switches
```fish
sub-abbr -- eza --long{,' --group'}`
```
[^eza-why-group]  
<img width="965" height="82" alt="ls-group" src="https://github.com/user-attachments/assets/bda2680d-980f-4834-ba41-a9086aa3afad" />
## Clarity
### Turning short flags into long
#### `eza`: long flag
```fish
sub-abbr -- eza -l --long`
```
<img width="684" height="82" alt="ls-longopt" src="https://github.com/user-attachments/assets/97a9b831-2cb5-4f44-a245-6ff01b217e41" />

#### Jujutsu: *Sub-Command* aliases
```fish
subabbr jj b{,ookmark}
subabbr jj ci commit
```
<img width="702" height="86" alt="jj-subcommands" src="https://github.com/user-attachments/assets/af0e2f6a-1ce3-4f3f-b9c1-242bca0e9471" />

---

# Usage: Arguments
## Positional
1. **Base Command**: The initial command that must precede the *Sub-Command*. (This is what differentiates `sub-abbr` from `abbr --position=anywhere`). Becomes the new *Base Command* for *Expansion*
2. **Sub-Command**: The *Sub-Command* to be replaced (expanded) by the *Expansion*. Comes after the *Base Command*
3. **Expansion**: The replacement (*Expansion*) of the typed *Sub-Command*. Becomes the new *Sub-Command* for *Base Command*
## Switches
- **Help**: Show a reference manual, consisting of the [purpose](#Purpose) & [arguments](#Usage-Arguments)
	* **Long**: *help*
	* **Short**: *h*
- **Prohibit `run0`**: Disable toleration of `run0` in the command prefix; i.e., do not expand the *Sub-Command* if the the *Base Command* is prefixed with `run0`
	* **Long**: *norun0*
	* **Short**: *0*
- **Regard Flags**: Acknowledge flags in the *Base Command*; If not set, switches in the *Base Command* are ignored
	* **Long**: regard-flags
	* **Short**: s
- Inherited switches [^inherited-switches]
	* Set Cursor
	* Color

---

# Installation
## User
[**Fisher**](https://github.com/jorgebucaran/fisher): `fisher install Drazape/fish-subAbbr`
## System
### Traditional Distributions
```fish
curl -fsSL 'https://raw.githubusercontent.com/Drazape/fish-subAbbr/main/install.fish' | run0 fish -NP
```
It will update each time it is run
## NixOS
A flake with convenient configuration options is planned.
### Workaround
For now, the installation can be worked-around (with automatic updates)
#### `flake.nix`:
```nix
{
	inputs = {
		fish-subAbbr = {
				type="github"; owner="Drazape"; repo="fish-subAbbr";
				flake = false;
		};
		…
	};
	outputs = inputs@{ self, nixpkgs, …, ... }: {
		nixosConfigurations."yourHost" = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit inputs; };
			…
		};
		…
	};
}
```
#### Module with the Fish configuration:
```nix
{ inputs, … }: {
	…
	programs.fish = {
		shellInit = ( # Fish subcommand abbreviation (workaround)
						builtins.concatStringsSep "\n" (
							builtins.map builtins.readFile 
								(builtins.map
									(subdir: inputs.fish-subAbbr + subdir + "/sub-abbr.fish")
									[ /functions /completions ]
								)
						)
		) + ''
			…
		'';
		…
};
```

[^simplification]: You can easily abbreviate base-commands, but there is no straight forward way to do the same with subcommands
[^nh-why-allow-root]: Security of system configuration, Multi-user environments, elevation happens internally anyway
[^eza-why-group]: Shows the group of the owned files. Default `long` switch in standard `ls` (I don't use this one, but you might want to if you see groups frequently. Why I am telling you this is that my aim is to set modern standards, not follow the legacy; as states my bio)
[^inherited-switches]: These are supported switches inherit from `abbr` that are not already being internally used, and thus can be passed to `sub-abbr`, which it passes directly to `abbr`
