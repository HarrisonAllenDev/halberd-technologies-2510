# **HALBERD TECHNOLOGIES - BHDQ Operations Account Creator:**
This software is used to automate account creation for the Tennessee Technological University Computer Science department on a fresh Ubuntu system. It allows the user to either automate account creation, or manually create new users by providing their first and last names.
## **Initial Requirements:**
Ensure that you have a fresh installation of Ubuntu 26.04 and BASH v5.3.9. This can either be natively installed on the host system, or can be run through a virtual machine (i.e. VMWare, VirtualBox, etc.).

## **How to Run**

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

On the first launch, you will be required to enter the 16-digit license key provided by the team. Follow the on-screen menu.

## **Troubleshooting**

**Permission denied / must run as root:**

```
sudo bash bhdq.sh
```

**No such file or directory:**

Make sure you are inside the repository folder:

```
cd halberd-technologies-2510
ls
sudo bash bhdq.sh
```

**Bad interpreter / ^M / Windows CRLF line endings:**

```
sudo apt install -y dos2unix
dos2unix *.sh
sudo bash bhdq.sh
```
**Permission denied / script not executable:**

Give specific bash scripts executable permissions:

```
chmod +x [file name your having trouble with ex. scraper.sh]
```
or give all bash scripts executable permissions:
```
chmod +x *
```
