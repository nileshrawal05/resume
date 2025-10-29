#!/bin/bash

# Function to compile the tex file
compile_latex() {
    local input_file=$1
    echo "Compiling $input_file..."
    
    # Run usr/local/texlive/2024/bin/x86_64-linux/pdflatex twice to resolve references
    pdflatex -interaction=nonstopmode "$input_file"
    if [ $? -ne 0 ]; then
        echo "Error: LaTeX compilation failed"
        return 1
    fi
    
    pdflatex -interaction=nonstopmode "$input_file"
    if [ $? -ne 0 ]; then
        echo "Error: LaTeX compilation failed"
        return 1
    fi
    
    echo "Compilation successful!"
    return 0
}

# Function to clean up auxiliary files
cleanup() {
    echo "Cleaning up auxiliary files..."
    rm -f *.aux *.log *.out *.toc *.lof *.lot *.fls *.fdb_latexmk *.synctex.gz
    echo "Cleanup complete!"
}

# Function to display usage information
show_usage() {
    echo "Usage: $0 [options] [tex_file]"
    echo "Options:"
    echo "  --clean        Clean up auxiliary files only (no compilation)"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 document.tex         # Compile the document and clean up auxiliary files"
    echo "  $0 --clean             # Just clean up auxiliary files"
    exit 1
}

# Main script
main() {
    local clean_only=false
    local tex_file=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                clean_only=true
                shift
                ;;
            -h|--help)
                show_usage
                ;;
            *)
                if [[ -z "$tex_file" ]]; then
                    tex_file="$1"
                else
                    echo "Error: Multiple input files specified"
                    show_usage
                fi
                shift
                ;;
        esac
    done

    # If clean_only flag is set, just clean up and exit
    if [ "$clean_only" = true ]; then
        cleanup
        exit 0
    fi

    # Check if input file is provided for compilation
    if [[ -z "$tex_file" ]]; then
        echo "Error: No input file specified"
        show_usage
    fi

    # Check if file exists and has .tex extension
    if [[ ! -f "$tex_file" ]]; then
        echo "Error: File '$tex_file' not found"
        exit 1
    fi

    if [[ "${tex_file##*.}" != "tex" ]]; then
        echo "Error: Input file must have .tex extension"
        exit 1
    fi

    
    # Compile the document
    if compile_latex "$tex_file"; then
        # Always clean up after successful compilation
        cleanup
        echo "PDF generation complete! Output file: ${tex_file%.tex}.pdf"
    else
        echo "PDF generation failed!"
        exit 1
    fi
}

# Run the script with all command line arguments
main "$@"
