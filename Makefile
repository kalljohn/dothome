# vim: set ts=4 sw=4 sts=4 ai

PREFIX 			= /usr/local

USER   = $(shell id -u -n)

ifeq ($(USER),root)
	SUDO 				=
	APT_INSTALL    		= apt-get install -y --no-install-recommends --no-upgrade
	APT_INSTALL_UPDATE 	= apt-get install -y --no-install-recommends
	APT_ADD_REPOSITORY 	= add-apt-repository -y
	APT_UPDATE          = apt-get update
	PREFIX_LOCAL 	    = $(PREFIX)
	MAKE_INSTALL        = make install
	MAKE_INSTALL_LOCAL  = $(MAKE_INSTALL)
else
	SUDO                = sudo
	APT_INSTALL    		= sudo apt-get install -y --no-install-recommends --no-upgrade
	APT_INSTALL_UPDATE  = sudo apt-get install -y --no-install-recommends
	APT_ADD_REPOSITORY 	= sudo add-apt-repository -y
	APT_UPDATE          = sudo apt-get update
	PREFIX_LOCAL 	    = $(HOME)/.local
	MAKE_INSTALL        = sudo make install
	MAKE_INSTALL_LOCAL  = make install
endif

RELEASE_VERSION = $(shell cut -d ' ' -f 2 /etc/issue | cut -d . -f 1)

CORES = $(shell cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)

WGET = wget --no-check-certificate

CMAKE_VERSION = 3.16.1

TMUX_VERSION = 3.0a
TMUX_TAR_FILENAME = tmux-$(TMUX_VERSION).tar.gz

TOOLS += sudo wget curl most less dos2unix tree
TOOLS += locales
TOOLS += mlocate
TOOLS += time man-db

# ssh tools
TOOLS += openssh-server openssh-client sshpass

# misc
TOOLS += htop
TOOLS += bash-completion
TOOLS += bzip2 xz-utils p7zip-full
TOOLS += python python-pip
TOOLS += python3 python3-dev python3-pip
TOOLS += aptitude

################################################################################
# ppa
################################################################################

HAS_PPA_VIM	    = $(shell grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep jonathonf/vim | wc -l)
HAS_PPA_FISH	= $(shell grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep fish-shell/release-3 | wc -l)

################################################################################
# programming tools
################################################################################

DEV_TOOLS += make automake autoconf build-essential binutils pkg-config

DEV_TOOLS += ninja-build

# compiler tools
DEV_TOOLS += ccache

# query system status.
DEV_TOOLS += sysstat net-tools
DEV_TOOLS += dstat

# trace system, shared library calls.
DEV_TOOLS += strace ltrace

# debuggers.
DEV_TOOLS += gdb gdbserver cgdb

# programming tools.
DEV_TOOLS += valgrind
DEV_TOOLS += prelink
DEV_TOOLS += astyle
DEV_TOOLS += httpie

################################################################################
# all
################################################################################

.PHONY: all
all: .init .mkdir base dev tool


.PHONY: .init
.init: .mkdir
	@echo make a link for bin folder ...
	[ -e ~/bin ] || ln -s `pwd`/bin ~/


.mkdir:
	@echo make build folder ...
	[ -d ./build ] || mkdir ./build


################################################################################
# base tools targets
################################################################################

.PHONY: base .base-apt

base: .base-apt
	-locale-gen en_US.UTF-8
	mandb


.base-apt:
	$(APT_INSTALL) $(TOOLS)


################################################################################
# programming tools targets
################################################################################

.PHONY: dev .dev-apt .dev-misc .dev-conf

dev: .init .dev-apt .dev-misc .dev-conf


.dev-apt:
	$(APT_INSTALL) $(DEV_TOOLS)


.dev-misc: cmake-bin


.dev-conf: gdb-conf ccache-conf


.PHONY: gdb-conf
gdb-conf:
	@echo config gdb ...
	-$(RM) ~/.gdbinit
	ln -s `pwd`/modules/gdbinit/gdbinit ~/.gdbinit
	-$(RM) ~/.gdbinit.local
	ln -s `pwd`/modules/gdb-dashboard/.gdbinit ~/.gdbinit.local


.PHONY: ccache-conf
ccache-conf:
	echo mkdir ~/.ccache folder ; mkdir -p ~/.ccache
	-$(RM) ~/.ccache/ccache.conf
	ln -s -f `pwd`/config/ccache/ccache.conf ~/.ccache/

.PHONY: cmake-bin

cmake-bin: .mkdir
	[ -f ./build/cmake-bin.tar.gz ] || $(WGET) -O ./build/cmake-bin.tar.gz https://github.com/Kitware/CMake/releases/download/v$(CMAKE_VERSION)/cmake-$(CMAKE_VERSION)-Linux-x86_64.tar.gz
	tar zxf ./build/cmake-bin.tar.gz -C $(PREFIX_LOCAL) --strip 1 --overwrite


################################################################################
# tools targets.
################################################################################

.PHONY: .ppa

ADD_APT_REPOSITORY_TOOLS = software-properties-common

ifeq ($(RELEASE_VERSION),16)
ADD_APT_REPOSITORY_TOOLS += python-software-properties
endif

.ppa:
	@command -v add-apt-repository >/dev/null 2>&1 || \
	( \
		echo install add-apt-repository tools ; \
		$(APT_INSTALL) $(ADD_APT_REPOSITORY_TOOLS) ; \
	)


# tool

.PHONY: tool

tool: git vim tmux fish fzf ripgrep


# git

.PHONY: git .git-apt git-conf

git: .git-apt git-conf


.git-apt:
	@command -v git >/dev/null 2>&1 || $(APT_INSTALL) git
	@command -v tig >/dev/null 2>&1 || $(APT_INSTALL) tig


git-conf:
	@echo config git
	git config --global core.ui true
	git config --global core.editor vim
	git config --global core.autocrlf input
	git config --global push.default simple
	git config --global alias.co checkout
	git config --global alias.br branch
	git config --global alias.ci commit
	git config --global alias.st status
	git config --global alias.unstage 'reset HEAD --'
	git config --global alias.last 'log -1 HEAD'
	git config --global http.sslverify false


#
# vim
#

.PHONY: vim .vim-ppa vim-apt vim-conf

vim: .vim-ppa .vim-apt vim-conf


# install the latest vim from ppa.
.vim-ppa: .ppa
	@[ $(HAS_PPA_VIM) -ne 0 ] || \
	( \
		echo add vim ppa ; \
		$(APT_ADD_REPOSITORY) ppa:jonathonf/vim ; \
	   	$(APT_UPDATE) \
	)


.vim-apt:
	$(APT_INSTALL) ctags cscope tidy libxml2-utils
	$(APT_INSTALL_UPDATE) vim


vim-conf:
	cd vimfiles && ./setup-plugins.sh
	[ -e ~/.vim ] || ln -s -f `pwd`/vimfiles ~/.vim


#
# tmux
#   install from source code.
#

.PHONY: tmux .tmux-buid .tmux-deps tmux-conf
.PHONY: tmux-apt .tmux-apt

# install from source code
tmux: .tmux-deps .tmux-build tmux-conf


.tmux-deps:
	@command -v wget >/dev/null 2>&1 || $(APT_INSTALL) wget
	$(APT_INSTALL) libevent-dev libncurses5-dev libutempter0


.tmux-build: .mkdir dev
	@[ -e $(PREFIX)/bin/tmux ] || \
	( \
		([ -f ./build/$(TMUX_TAR_FILENAME) ] || $(WGET) -O ./build/$(TMUX_TAR_FILENAME) https://github.com/tmux/tmux/releases/download/$(TMUX_VERSION)/$(TMUX_TAR_FILENAME)) ; \
		(cd ./build && tar zxf $(TMUX_TAR_FILENAME) && cd ./tmux-$(TMUX_VERSION) && ([ ! -f Makefile ] || make distclean)) ; \
		(cd build/tmux-$(TMUX_VERSION) && ./configure --prefix=$(PREFIX) && make -j$(CORES) && $(MAKE_INSTALL)) \
	)


tmux-conf:
	-$(RM) ~/.tmux-conf
	ln -s -f `pwd`/config/tmux/tmux.conf ~/.tmux.conf
	@[ -d ~/.tmux ] || mkdir -p ~/.tmux
	-$(RM) -rf ~/.tmux/plugins
	ln -s -f `pwd`/config/tmux/plugins ~/.tmux/plugins


#
# fish-shell
#   install from apt
#

.PHONY: fish .fish-deps fish-conf
.PHONY: fish-apt .fish-ppa .fish-apt

fish: .fish-apt fish-conf


# install from apt
.fish-apt: .fish-ppa
	$(APT_INSTALL) fish


# install the latest fish from ppa.
.fish-ppa: .ppa
	@[ $(HAS_PPA_FISH) -ne 0 ] || \
	( \
		echo add fish ppa ; \
		$(APT_ADD_REPOSITORY) ppa:fish-shell/release-3 ; \
	   	$(APT_UPDATE) \
	)


fish-conf:
	#@echo change default shell to fish shell.
	#$(SUDO) chsh -s /usr/bin/fish $(USER)
	echo mkdir ~/.config/fish/functions folder ; mkdir -p ~/.config/fish/functions
	cp -af `pwd`/config/fish/functions/* ~/.config/fish/functions/
	-$(RM) ~/.config/fish/fishfile
	cp -af `pwd`/config/fish/fishfile ~/.config/fish/
	-$(RM) ~/.config/fish/config.fish
	ln -s -f `pwd`/config/fish/config.fish ~/.config/fish/
	curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
	fish && fisher


#
# fzf (A command-line fuzzy finder)
# can cowork with bash, zsh or fish shells
#

.PHONY: fzf

fzf:
	[ -d ~/.fzf ] || git clone https://github.com/junegunn/fzf ~/.fzf
	[ -d ~/.fzf ] && (~/.fzf/install --all)

#
# ripgrep: recursively searches directories for a regex pattern
# https://github.com/BurntSushi/ripgrep
#

.PHONY: ripgrep .ripgrep-deps

ripgrep: .ripgrep-deps
	@command -v rg >/dev/null 2>&1 || \
	( \
		([ -e ./build ] || mkdir build ) && \
		([ -f ./build/ripgrep_amd64.deb ] || $(WGET) https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb -O ./build/ripgrep_amd64.deb) && \
		$(SUDO) dpkg -i ./build/ripgrep_amd64.deb \
	)


.ripgrep-deps:
	@command -v wget >/dev/null 2>&1 || $(APT_INSTALL) wget
