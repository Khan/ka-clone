.PHONY: tests lint clean

tests:
	cram -v examples/*.t

lint:
	ka-lint --lang=python bin/ka-clone

clean:
	rm examples/*.t.err
