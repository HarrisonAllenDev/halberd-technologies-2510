
# How to Run

**1. Ensure you have curl installed**

```
sudo apt install curl
```

**2. Download the program**

Github CLI:
```
gh repo clone HarrisonAllenDev/halberd-technologies-2510
```
or download it from:

```
https://github.com/HarrisonAllenDev/halberd-technologies-2510
```

**3. Extract the folder**

Right click on the zipped folder and press "Extract"

**4. Enter the extracted folders directory**

```
cd ~/Downloads/halberd-technologies-2510-main
```

**5. Run the Program**

```
sudo bash bhdq.sh
```

On the first launch, enter the 16-digit license key provided by the team. Follow the on-screen menu.

## **Troubleshooting**

Permission denied / must run as root

```
sudo bash bhdq.sh
```

No such file or directory

Make sure you are inside the repository folder:

```
cd halberd-technologies-2510
ls
sudo bash bhdq.sh
```

Bad interpreter / ^M / Windows CRLF line endings

```
sudo apt install -y dos2unix
dos2unix *.sh
sudo bash bhdq.sh
```
Permission denied / script not executable

Give the Bash scripts executable permissions:

```
chmod +x [file name your having trouble with ex. scraper.sh]
```
