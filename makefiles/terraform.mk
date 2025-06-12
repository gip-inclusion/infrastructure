##@ Terraform

TF_INIT_ALL_OPTS ?=
TF_PLAN_ALL_OPTS ?=
TF_APPLY_ALL_OPTS ?=

ifeq ($(CI),true)
  TF_INIT_ALL_OPTS += -input=false -no-color
  TF_PLAN_ALL_OPTS += -input=false -no-color
  TF_APPLY_ALL_OPTS += -input=false -no-color -auto-approve
endif


.PHONY: terraform-show
terraform-show: guard-SERVICE  ## Show infrastructure (SERVICE=xxx)
	@printf "%b[%s] Show infrastructure%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@cd $(SERVICE)/terraform \
		&& ( which tfswitch && tfswitch || true ) \
		&& terraform init -reconfigure \
		&& terraform show

.PHONY: terraform-validate
terraform-validate: guard-SERVICE  ## Validate infrastructure (SERVICE=xxx)
	@printf "%b[%s] variablealidate infrastructure%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	cd $(SERVICE)/terraform \
		&& ( which tfswitch && tfswitch || true ) \
		&& terraform init -reconfigure \
		&& terraform validate

.PHONY: terraform-validate-all
terraform-validate-all:  ## Validate infrastructure for all services
	@printf "%b[%s] Validate all infrastructure%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@ROOT_DIR=$$(pwd); \
	find . -type f -name "main.tf" \
		-not -path "*/.terraform/*" \
		-exec dirname {} \; \
		| sort -u \
		| while read dir; do \
		  echo "Processing $$dir"; \
		  cd "$$dir"; \
		  which tfswitch && tfswitch || true; \
		  terraform init -reconfigure $(TF_INIT_ALL_OPTS); \
		  terraform validate; \
		  cd "$$ROOT_DIR"; \
		done

.PHONY: terraform-plan
terraform-plan: guard-SERVICE  ## Plan infrastructure (SERVICE=xxx)
	@printf "%b[%s] Plan infrastructure%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	cd $(SERVICE)/terraform \
		&& ( which tfswitch && tfswitch || true ) \
		&& terraform init -reconfigure \
		&& terraform plan -lock-timeout=60s -var-file=terraform.tfvars

.PHONY: terraform-plan-all
terraform-plan-all:  ## Plan infrastructure for all services
	@printf "%b[%s] Plan all infrastructure%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@ROOT_DIR=$$(pwd); \
	find . -type f -name "main.tf" \
		-not -path "./infrastructure/_modules/*" \
		-not -path "*/.terraform/*" \
		-exec dirname {} \; \
		| sort -u \
		| while read dir; do \
		  echo "Processing $$dir"; \
		  cd "$$dir"; \
		  which tfswitch && tfswitch || true; \
		  terraform init -reconfigure $(TF_INIT_ALL_OPTS); \
		  terraform plan -lock-timeout=60s -var-file=terraform.tfvars $(TF_PLAN_ALL_OPTS); \
		  cd "$$ROOT_DIR"; \
		done

.PHONY: terraform-apply
terraform-apply: guard-SERVICE  ## Apply changes on infrastructure (SERVICE=xxx)
	@printf "%b[%s] Apply infrastructure%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@cd $(SERVICE)/terraform \
		&& ( which tfswitch && tfswitch || true ) \
		&& terraform init -reconfigure \
		&& terraform apply -lock-timeout=60s -var-file=terraform.tfvars

.PHONY: terraform-apply-all
terraform-apply-all:  ## Apply changes on infrastructure for all services
	@printf "%b[%s] Apply all infrastructure%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@ROOT_DIR=$$(pwd); \
	find . -type f -name "main.tf" \
		-not -path "./infrastructure/_modules/*" \
		-not -path "*/.terraform/*" \
		-exec dirname {} \; \
		| sort -u \
		| while read dir; do \
		  echo "Processing $$dir"; \
		  cd "$$dir"; \
		  which tfswitch && tfswitch || true; \
		  terraform init -reconfigure $(TF_INIT_ALL_OPTS); \
		  terraform apply -lock-timeout=60s -var-file=terraform.tfvars $(TF_APPLY_ALL_OPTS); \
		  cd "$$ROOT_DIR"; \
		done

.PHONY: terraform-destroy
terraform-destroy: guard-SERVICE  ## Destroy infrastructure (SERVICE=xxx)
	@printf "%b[%s] Destroy infrastructure%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@cd $(SERVICE)/terraform \
		&& ( which tfswitch && tfswitch || true ) \
		&& terraform init -reconfigure \
		&& terraform destroy -lock-timeout=60s -var-file=terraform.tfvars

.PHONY: terraform-providers-lock
terraform-providers-lock: guard-SERVICE  ## Make multiplatform providers locks (SERVICE=xxx)
	@printf "%b[%s] Lock providers%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@cd $(SERVICE)/terraform \
		&& ( which tfswitch && tfswitch || true ) \
		&& terraform init -reconfigure \
		&& terraform providers lock -platform=darwin_amd64 -platform=linux_amd64 -platform=darwin_arm64

.PHONY: terraform-providers-lock-all
terraform-providers-lock-all:  ## Make multiplatform providers locks for all services
	@printf "%b[%s] Lock all providers%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@find . -type f -name "main.tf" \
		-not -path "./infrastructure/_modules/*" \
		-not -path "*/.terraform/*" \
		-exec dirname {} \; \
		| sort -u \
		| while read dir; do \
		  echo "Processing $$dir"; \
		  cd "$$dir"; \
		  which tfswitch && tfswitch || true; \
		  terraform init -reconfigure $(TF_INIT_ALL_OPTS); \
		  terraform providers lock -platform=darwin_amd64 -platform=linux_amd64 -platform=darwin_arm64; \
		  cd "$$ROOT_DIR"; \
		done

.PHONY: terraform-upgrade
terraform-upgrade:  ## Upgrade terraform providers
	@printf "%b[%s] Upgrade terraform providers%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@cd $(SERVICE)/terraform \
		&& ( which tfswitch && tfswitch || true ) \
		&& terraform init -upgrade

.PHONY: terraform-upgrade-all
terraform-upgrade-all:  ## Upgrade all terraform providers
	@printf "%b[%s] Upgrade terraform providers%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@find . -type f -name "main.tf" \
		-not -path "./infrastructure/_modules/*" \
		-not -path "*/.terraform/*" \
		-exec dirname {} \; \
		| sort -u \
		| while read dir; do \
		  echo "Processing $$dir"; \
		  cd "$$dir"; \
		  which tfswitch && tfswitch || true; \
		  terraform init -upgrade $(TF_INIT_ALL_OPTS); \
		  cd "$$ROOT_DIR"; \
		done

.PHONY: terraform-output
terraform-output: guard-SERVICE guard-KEY  ## Show output (SERVICE=xxx KEY=xxx)
	@printf "%b[%s] Plan infrastructure%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	cd $(SERVICE)/terraform \
		&& ( which tfswitch && tfswitch || true ) \
		&& terraform init -reconfigure \
		&& terraform output $(KEY)

.PHONY: terraform-rm-providers-cache
terraform-rm-providers-cache:  ## Delete terraform providers cache
	@printf "%b[%s] Delete terraform providers cache%b\n" "$(OK_COLOR)" "$(BANNER)" "$(NO_COLOR)"
	@find . -type d -path "*/.terraform/providers" -prune -exec rm -rf {} \;
