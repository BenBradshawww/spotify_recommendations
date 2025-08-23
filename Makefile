STACK ?= app
STACK_DIR = infra/modules/$(STACK)
COMMON_VARS = -var-file=../../vars/comm.tfvars
SECRET_VARS = -var-file=../../vars/secrets.tfvars

VARS = $(COMMON_VARS) $(SECRET_VARS)

init:
	terraform -chdir=$(STACK_DIR) init

plan:
	terraform -chdir=$(STACK_DIR) init
	terraform -chdir=$(STACK_DIR) plan $(VARS)

apply:
	terraform -chdir=$(STACK_DIR) apply -auto-approve $(VARS)

destroy:
	terraform -chdir=$(STACK_DIR) destroy -auto-approve $(VARS)

fmt:
	terraform fmt -recursive

validate:
	terraform -chdir=$(STACK_DIR) validate

output:
	terraform -chdir=$(STACK_DIR) output

show:
	terraform -chdir=$(STACK_DIR) show