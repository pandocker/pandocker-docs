ifeq ($(OS),Windows_NT)
HOME = C:/Users/$(USERNAME)
endif
PIPBASE= $(shell get-pip-base)
PANSTYLES= $(PIPBASE)/var
MISC= $(PANSTYLES)/pandoc_misc
MISC_SYS = $(MISC)/system
MISC_USER = $(MISC)/user
include $(MISC_SYS)/Makefile.in
PROJECT= `pwd`

## userland: uncomment and replace
# MDDIR:= markdown
# DATADIR:= data
# TARGETDIR:= Out
# IMAGEDIR:= images
# WAVEDIR:= waves
# BITDIR:= bitfields
# BIT16DIR:= bitfield16

# CONFIG:= config.yaml
# INPUT:= TITLE.md
BRANCH:= '$(shell git rev-parse --abbrev-ref HEAD)'
TARGET:= Pandocker-Docs-$(BRANCH)-$(HASH)
# COREPROPFLAGS := --table "Normal Table=Centered"
# COREPROPFLAGS += --paragraph "Normal=Body Text"
##
include $(MISC_SYS)/Makefile
