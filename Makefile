PREFIX=/usr/local
TASK_DONE = echo -e "\n✓ $@ done\n"
# files that need mode 755
EXEC_FILES=tv.sh

.PHONY: test

all:
	@echo "usage: make install"
	@echo "       make reinstall"
	@echo "       make uninstall"
	@echo "       make test"

help:
	$(MAKE) all
	@$(TASK_DONE)

install:
	install -m 0755 $(EXEC_FILES) $(PREFIX)/bin
	@$(TASK_DONE)

uninstall:
	test -d $(PREFIX)/bin && \
	cd $(PREFIX)/bin && \
	rm -f $(EXEC_FILES) && \
	@$(TASK_DONE)

reinstall:
	@curl -s https://raw.githubusercontent.com/arzzen/philips-tv/master/tv.sh > tv.sh
	$(MAKE) uninstall && \
	$(MAKE) install
	@$(TASK_DONE)

