import argparse
import os
import subprocess
import sys


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="""Run terraform-docs on a set of files. Follows the standard convention of
                       pulling the documentation from main.(tf|tofu) in order to replace the entire
                       README.md file each time."""
    )
    parser.add_argument(
        "--dest",
        dest="dest",
        default="README.md",
    )
    parser.add_argument(
        "--sort-inputs-by-required",
        dest="sort",
        action="store_true",
        help="[deprecated] use --sort-by-required instead",
    )
    parser.add_argument(
        "--sort-by-required",
        dest="sort",
        action="store_true",
    )
    parser.add_argument(
        "--with-aggregate-type-defaults",
        dest="aggregate",
        action="store_true",
        help="[deprecated]",
    )
    parser.add_argument("filenames", nargs="*", help="Filenames to check.")
    args = parser.parse_args(argv)

    dirs = []
    seen_dirs = set()
    for filename in args.filenames:
        if filename.endswith((".tf", ".tofu", ".tfvars")):
            dir_path = os.path.dirname(filename)
            dir_key = os.path.realpath(dir_path)
            if dir_key not in seen_dirs:
                seen_dirs.add(dir_key)
                dirs.append(dir_path)

    retval = 0

    for dir in dirs:
        try:
            procArgs = []
            procArgs.append("terraform-docs")
            if args.sort:
                procArgs.append("--sort-by-required")
            procArgs.append("md")
            procArgs.append("./{dir}".format(dir=dir))
            procArgs.append(">")
            procArgs.append("./{dir}/{dest}".format(dir=dir, dest=args.dest))
            subprocess.check_call(" ".join(procArgs), shell=True)
        except subprocess.CalledProcessError as e:
            print(e)
            retval = 1
    return retval


if __name__ == "__main__":
    sys.exit(main())
