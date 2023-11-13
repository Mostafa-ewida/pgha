# what is this do 
This is a bash project to Create High Availability and auto-fail-over **Postgres Clutster**  

# requirements 
- 2 ubuntu  machines running 
- A Virtual ip

# Installation



### Setting up the scripts on master node 

```bash
#getting the master scripts
wget https://github.com/Mostafa-ewida/pgha/blob/main/masterpg1.sh
wget https://github.com/Mostafa-ewida/pgha/blob/main/masterpg2.sh

#change permissions
chmod +x masterpg1.sh masterpg2.sh

```


### Setting up the scripts on slave node

```bash
#getting the master scripts
wget https://github.com/Mostafa-ewida/pgha/blob/main/slavepg1.sh
wget https://github.com/Mostafa-ewida/pgha/blob/main/slavepg2.sh

#change permissions
chmod +x slavepg1.sh slavepg2.sh

```

### running **1st** set of scripts
**ON MASTER**

```bash 
./masterpg1.sh [Worker IP] [Admin IP]
```
```bash 
#example 
./masterpg1.sh 192.168.1.13 192.168.1.30
```

**ON SlAVE**

```bash 
./slavepg1.sh [Master IP] [Admin IP]
```
```bash 
#example 
./masterpg1.sh 192.168.1.12 192.168.1.30
```




### running **2st** set of scripts
**ON MASTER**

```bash 
./masterpg2.sh [Worker IP] [Virtual IP]
```
```bash 
#example 
./masterpg2.sh 192.168.1.13 192.168.1.100
```

**ON SlAVE**

```bash 
./slavepg2.sh [Master IP] [Virtual IP]
```
```bash 
#example 
./slavepg1.sh 192.168.1.12 192.168.1.100
```

# Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

# License

[GPL3.0](https://choosealicense.com/licenses/gpl-3.0/)
