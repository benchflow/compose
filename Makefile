REPONAME = compose
DOCKERIMAGENAME = benchflow/$(REPONAME)
VERSION = dev
JAVA_VERSION_FOR_COMPILATION = java-8-oracle
UNAME = $(shell uname)
JAVA_HOME := `update-java-alternatives -l | cut -d' ' -f3 | grep $(JAVA_VERSION_FOR_COMPILATION)`

find_java:
ifeq ($(UNAME), Darwin)
	$(eval JAVA_HOME := $(shell /usr/libexec/java_home))
endif

.PHONY: all build_release 

all: build_release

clean:
	mvn clean

build: find_java
	JAVA_HOME=$(JAVA_HOME) mvn package

build_release: find_java
	JAVA_HOME=$(JAVA_HOME) mvn install

install: find_java
	update-java-alternatives -l 
	JAVA_HOME=$(JAVA_HOME) mvn install

test: find_java
	JAVA_HOME=$(JAVA_HOME) mvn test -B

build_container:
	docker build -t $(DOCKERIMAGENAME):$(VERSION) -f Dockerfile .

build_container_local: find_java
	JAVA_HOME=$(JAVA_HOME) mvn package
	docker build -t $(DOCKERIMAGENAME):$(VERSION) -f Dockerfile.test .
	rm target/benchflow-$(REPONAME).jar

test_container_local:
	docker run -ti --rm -e "BENCHFLOW_SWARM_ENDPOINT=$(BENCHFLOW_SWARM_ENDPOINT)" -e "BENCHFLOW_SWARM_TLSVERIFY=0" -e "ENVCONSUL_CONSUL=$(ENVCONSUL_CONSUL)" \
	-p 8080:8080 --net="host" --name $(REPONAME) $(DOCKERIMAGENAME):$(VERSION)

rm_container_local:
	docker rm -f -v $(REPONAME)