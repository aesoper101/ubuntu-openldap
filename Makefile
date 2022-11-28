NAME = aesoper/openldap
VERSION = v1.0.0

LOCAL_CERTS_PATH = ./certs
VOLUME_CERTS_PATH = ./testdata/assets/certs

.PHONY: build build-nocache test tag-latest push push-latest release git-tag-version

build:
	docker build -t $(NAME):$(VERSION) --rm -f ./Dockerfile .

build-test:
	docker-compose down -v
	docker image rm $(NAME):$(VERSION)
	docker build -t $(NAME):$(VERSION) --rm -f ./Dockerfile .
	docker-compose up

build-nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm image

test:
	env NAME=$(NAME) VERSION=$(VERSION) bats test/test.bats

tag:
	docker tag $(NAME):$(VERSION) $(NAME):$(VERSION)

tag-latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

push:
	docker push $(NAME):$(VERSION)

push-latest:
	docker push $(NAME):latest

release: build test tag-latest push push-latest

git-tag-version:
	git tag -a $(VERSION) -m "$(VERSION)"
	git push origin $(VERSION)

#gen-ca-config:
#	cfssl print-defaults config > $(LOCAL_CERTS_PATH)/ca-config.json
#
#gen-csr-config:
#	cfssl print-defaults csr > $(LOCAL_CERTS_PATH)/ca-csr.json

gen-ca:
	cfssl gencert -initca $(LOCAL_CERTS_PATH)/ca-csr.json | cfssljson -bare ca
	cp -f ca.pem $(VOLUME_CERTS_PATH)
	mv -f  *.pem *.csr $(LOCAL_CERTS_PATH)

gen-server-csr-config:
	cfssl print-defaults csr > $(LOCAL_CERTS_PATH)/server-csr.json

gen-server-csr:
	cfssl gencert -ca=$(LOCAL_CERTS_PATH)/ca.pem -ca-key=$(LOCAL_CERTS_PATH)/ca-key.pem \
     --config=$(LOCAL_CERTS_PATH)/ca-config.json -profile=ldap \
     $(LOCAL_CERTS_PATH)/server-csr.json | cfssljson -bare server
	cp -f  server.pem server-key.pem $(VOLUME_CERTS_PATH)
	mv -f  *.pem *.csr $(LOCAL_CERTS_PATH)


gen-dhparam:
	openssl dhparam -out $(LOCAL_CERTS_PATH)/dhparam.pem 4096
	mv -f $(LOCAL_CERTS_PATH)/dhparam.pem $(VOLUME_CERTS_PATH)

#gen-csr-config: gen-ca-config gen-server-csr-config


gen-cert: gen-ca gen-server-csr gen-dhparam


