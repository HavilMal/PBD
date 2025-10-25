import argparse

def main():
    parser = argparse.ArgumentParser(description="Append text to a file.")
    parser.add_argument("filename", help="The file to append to")
    parser.add_argument('-o', action='store_true')
    parser.add_argument("text", help="The text to append to the file")
    args = parser.parse_args()

    mode = '+w' if args.o else '+a'

    with open(args.filename, mode, encoding='utf-8') as file:
        file.write(args.text + "\n")

if __name__ == "__main__":
    main()