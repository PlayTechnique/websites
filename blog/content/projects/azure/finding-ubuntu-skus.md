---
title: "Finding Ubuntu Skus"
date: 2022-11-22T08:28:47-07:00
draft: false
---
The ubuntu offerings on azure flip between dot delimited versions like 20.04 and underscore delimited like 22_04.

To find the right labels:

1. Search the azure marketplace for your ubuntu image (https://portal.azure.com/#view/Microsoft_Azure_Marketplace)
2. Click on the image name and then select the Usage Information + Support tab. Here you'll find the publisher name and the product ID.
3. `PUBLISHER=ubuntu PRODUCT_ID=0001-com-ubuntu-server-jammy az vm image list-skus --publisher ${PUBLISHER}  --offer ${PRODUCT_ID} --location westus`
In the output of this command you'll see an ID which contains the SKU 
