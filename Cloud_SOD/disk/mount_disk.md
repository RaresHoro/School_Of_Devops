# Partition and Mount a New Data Disk on Azure Linux VM

This guide explains how to partition, format, and mount a newly attached data disk (e.g., `/dev/sdc`) on your Azure Linux VM.

---

## 🔍 Step 1: Identify the Disk

SSH into your VM and run:

```bash
lsblk
```

Look for a disk with **no partitions or mount point**. Example output:

```
sdc       8:32   0   64G  0 disk
```

This is your **new 64 GB disk**.

---

## 🧱 Step 2: Partition the Disk

Use `fdisk` to create a new partition on `/dev/sdc`:

```bash
sudo fdisk /dev/sdc
```

Follow this interactive sequence:

1. Press `n` — create new partition
2. Press `p` — primary partition
3. Press `1` — partition number
4. Press `Enter` — accept default first sector
5. Press `Enter` — accept default last sector (use full disk)
6. Press `w` — write changes and exit

You now have a partition: `/dev/sdc1`.

---

## 🧪 Step 3: Format the Partition

Format the new partition with the `ext4` file system:

```bash
sudo mkfs.ext4 /dev/sdc1
```

---

## 📂 Step 4: Mount the Disk

Create a mount point and mount the disk:

```bash
sudo mkdir /mnt/data
sudo mount /dev/sdc1 /mnt/data
```

Verify with:

```bash
df -h
```

You should see `/dev/sdc1` mounted at `/mnt/data`.

---

## 🔁 Step 5: Make the Mount Persistent

To ensure the disk is remounted on reboot:

1. Get the UUID:

```bash
sudo blkid /dev/sdc1
```

2. Edit `/etc/fstab`:

```bash
sudo nano /etc/fstab
```

3. Add the following line (replace with your actual UUID):

```
UUID=your-uuid-here /mnt/data ext4 defaults,nofail 0 2
```

4. Save and exit.

5. Test:

```bash
sudo mount -a
```

If no errors occur, you're done!

---

## ✅ Done

Your new disk is now:

* Partitioned
* Formatted
* Mounted at `/mnt/data`
* Automatically persistent across reboots

