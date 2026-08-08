all: format build

format:
    typstyle -l=120 -i .

build:
    typst compile ./paper.typ ./paper.pdf

watch:
    typst watch ./paper.typ ./paper.pdf
