{
	description = "pi pico";

	outputs = { self, nixpkgs }: {

		packages.x86_64-linux = let
			pkgs = nixpkgs.legacyPackages.x86_64-linux;
		in rec {
			pico-sdk = pkgs.pico-sdk.overrideAttrs (old: {
				src = pkgs.fetchFromGitHub {
					owner = "raspberrypi";
					repo = "pico-sdk";
					rev = "1.5.1";
					hash = "sha256-GY5jjJzaENL3ftuU5KpEZAmEZgyFRtLwGVg3W1e/4Ho=";
					fetchSubmodules = true;
				};
			});
			pico_image = pkgs.stdenv.mkDerivation {
				src = ./src;
				pname = "pico_image";
				version = "1.0";
				nativeBuildInputs = with pkgs; [ cmake gcc-arm-embedded python3 ];
				cmakeFlags = [
					"-DPICO_SDK_PATH=${pico-sdk}/lib/pico-sdk/"
					"-DPICO_TOOLCHAIN_PATH=${pkgs.gcc-arm-embedded}/bin"
					"-DCMAKE_C_COMPILER=${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-gcc"
					"-DCMAKE_CXX_COMPILER=${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-g++"
					"-DPICO_BOARD=pico_w"
				];
				installPhase = ''
					mkdir -p $out
					mv ./hello_world.uf2 $out/
				'';
			};
			pico_flash = pkgs.writeScriptBin "pico_flash" ''
				set -x
				set -e
				TMPMOUNT=$(mktemp -d)
				sudo mount /dev/disk/by-id/usb-RPI_RP2*-part1 $TMPMOUNT || { rmdir $TMPMOUNT; false; }
				sudo cp ${pico_image}/* $TMPMOUNT/
				sudo umount $TMPMOUNT
				sudo rmdir $TMPMOUNT
			'';
			default = pico_flash;
		};

		devShells.x86_64-linux.default = let
			pkgs = nixpkgs.legacyPackages.x86_64-linux;
			pico-sdk = self.packages.x86_64-linux.pico-sdk;
		in pkgs.mkShell {
			nativeBuildInputs = [
				pico-sdk
			] ++ (with pkgs; [
				cmake
				gcc-arm-embedded
				git
			]);
			shellHook = ''
				export PICO_SDK_PATH=${pico-sdk}/lib/pico-sdk/
				export CMAKE_C_COMPILER=${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-gcc
			'';
		};

	};
}
