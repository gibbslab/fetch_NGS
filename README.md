# **Fetchngs Pipeline From nf-core**

Fetchngs pipeline constitutes several built-in programs/scripts to retrieve metadata and raw FASTQ files from public and private databases such as SRA, ENA, DDBJ, GEO and Synapse. This pipeline is supported by [nf-core](https://nf-co.re/fetchngs)


## **Instalation**

Fetchngs is built using Nextflow, a workflow tool to run tasks across multiple compute infrastructures and it also uses Docker/Singularity containers making installation trivial and results highly reproducible. This guide covers the installation and configuration for Ubuntu


### **Nextflow**

a. Make sure that Java v8+ is installed

```
java -version
```

b. Install Nextflow

```
curl -fsSL get.nextflow.io | bash
```

c. Move the file to a directory accessible by your `$PATH` variable

```
sudo mv nextflow /usr/local/bin/
```


### **Docker**

For more information, visit [Docker website](https://docs.docker.com/)

a. Update the apt package index, and install the latest version of Docker Engine

```
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

b. List the versions available in your repo

```
apt-cache madison docker-ce
```

c. Install a specific version

```
sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
```

d. Verify that Docker is installed correctly by running the hello-world image

```
sudo docker run hello-world
```

e. Enable Docker permissions

```
sudo chmod 666 /var/run/docker.sock
```


### **nf-core**

a. Install nf-core tools

```
sudo pip3 install nf-core
```

b. List all nf-core pipelines and show available updates

```
nf-core list
```


## **Usage**

To simplify the process, a `scr/fetch-data.sh` script provides a safe and efficient method for fetching data

```
bash fetch-data.sh -i Astro_IDs.txt -t sra -p 8 -m 230 -n Astrocyte -x n
```


## **Arguments**


### **Mandatory**


-	`-i:` Identifiers provided in a txt file, one per line. These can be from SRA, ENA, DDBJ, GEO or Synapse repositories. An example is available in `data`

-	`-t:` Specifies the type of identifier provided: `sra`, `synapse`

-	`-p:` CPUs

-	`-m:` Max memory to be used

-	`-n:`  Samplesheet name for direct use with the nf-core/rna-seq pipeline will be created (CSV)

-	`-x: ` This execution is a resume of a previous run or it is a new run. The options are: `y` or `n`



## **Running in the background**

The Nextflow `-bg` flag launches Nextflow in the background or alternatively, you can use `screen/tmux` or similar tool to create a detached session which you can log back into at a later time



## **Result**

The script will create a local directory based on the type identifier provided. Within this directory, the following will be found

-	`result:` Contains metadata and raw FASTQC files

-	`work:` Contains the main pipeline workflows

-	`20220113-001006.COMMAND:` Contains the commands used for the actual launch. File name contains the date (%y%m%d) and the time (%H%M%S) when the command was last run. Thus, if it is resumed, it will be overwritten



## **Bug Reports**

Please report bugs through the GitHub issues system
