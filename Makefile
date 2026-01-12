build: 
	cd $(REPO) && make entdev-linux-ui
	cp $(REPO)/bin/vault .

gen-ami:
	packer init vault.pkr.hcl
	packer build vault.pkr.hcl

run-instance:
	terraform init
	terraform apply -auto-approve

deploy: build gen-ami run-instance

destroy:
	terraform destroy -auto-approve