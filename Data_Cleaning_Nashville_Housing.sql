--CLEANING DATA USING SQL QUERIES

Select *
From Data_Cleaning.dbo.NashvilleHousing



--------------------------------------------------
--Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
From Data_Cleaning.dbo.NashvilleHousing


ALter Table Data_Cleaning.dbo.NashvilleHousing
Alter Column SaleDate Date NOT NULL

Select SaleDate
From Data_Cleaning.dbo.NashvilleHousing



--------------------------------------------------
--Deal with Missing Values in Property Address Data

Select PropertyAddress
From Data_Cleaning.dbo.NashvilleHousing
Where PropertyAddress is Null


Select *
From Data_Cleaning.dbo.NashvilleHousing
--Where PropertyAddress is Null
Order by ParcelID  

--Check if houses with the same ParcelID has the same address, we can use this to match and recover the missing addresses
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From Data_Cleaning.dbo.NashvilleHousing a
Join Data_Cleaning.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

--Replace Missing Values
Update a
Set a.PropertyAddress = isNull(a.PropertyAddress, b.PropertyAddress)
From Data_Cleaning.dbo.NashvilleHousing a
Join Data_Cleaning.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

--Check if there are null values left
Select PropertyAddress
From Data_Cleaning.dbo.NashvilleHousing
Where PropertyAddress is Null



--------------------------------------------------
--Separate House Address into Columns (Address, City)

Select PropertyAddress
From Data_Cleaning.dbo.NashvilleHousing

--For PropertyAddress, Street Address and City are separated by a comma
--Take Substring from start position to before the comma to get the Street Address
Select Substring(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1) as StreetAddress,
	Substring(PropertyAddress, CharIndex(',', PropertyAddress) + 2, len(PropertyAddress)) as City
From Data_Cleaning.dbo.NashvilleHousing

--Create new columns for StreetAddress and City
--StreetAddress
Alter Table Data_Cleaning.dbo.NashvilleHousing
Add StreetAddress Nvarchar(255);

Update Data_Cleaning.dbo.NashvilleHousing
Set StreetAddress = Substring(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1)

--City
Alter Table Data_Cleaning.dbo.NashvilleHousing
Add City Nvarchar(255);

Update Data_Cleaning.dbo.NashvilleHousing
Set City = Substring(PropertyAddress, CharIndex(',', PropertyAddress) + 2, len(PropertyAddress))

--Check Result
Select *
From Data_Cleaning.dbo.NashvilleHousing


--Separate OwnerAddress into Columns (Address, City, State)
Select 
	ParseName(Replace(OwnerAddress, ',', '.'), 3),  --ParseName only works for periods
	ParseName(Replace(OwnerAddress, ',', '.'), 2),
	ParseName(Replace(OwnerAddress, ',', '.'), 1)
From Data_Cleaning.dbo.NashvilleHousing


--Create new columns for OwnerStreetAddress, OwnerCity, and OwnerState
--OwnerStreetAddress
Alter Table Data_Cleaning.dbo.NashvilleHousing
Add OwnerStreetAddress Nvarchar(255);

Update Data_Cleaning.dbo.NashvilleHousing
Set OwnerStreetAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)

--OwnerCity
Alter Table Data_Cleaning.dbo.NashvilleHousing
Add OwnerCity Nvarchar(255);

Update Data_Cleaning.dbo.NashvilleHousing
Set OwnerCity = ParseName(Replace(OwnerAddress, ', ', '.'), 2)

--OwnerState
Alter Table Data_Cleaning.dbo.NashvilleHousing
Add OwnerState Nvarchar(255);

Update Data_Cleaning.dbo.NashvilleHousing
Set OwnerState = ParseName(Replace(OwnerAddress, ', ', '.'), 1)


--Check Result
Select *
From Data_Cleaning.dbo.NashvilleHousing



--------------------------------------------------
--Replacing odd values 'Y' and 'N' with 'Yes' and 'No'

--Look at values in SoldAsVacant column
Select Distinct(SoldAsVacant)
From Data_Cleaning.dbo.NashvilleHousing


Select Distinct(SoldAsVacant), Count(SoldAsVacant) as Frequency
From Data_Cleaning.dbo.NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant


Update Data_Cleaning.dbo.NashvilleHousing
Set SoldAsVacant =
	Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End



--------------------------------------------------
--Deleting Columns (if necessary)

Alter Table Data_Cleaning.dbo.NashvilleHousing
Drop Column PropertyAddress, OwnerAddress   --since we already converted these columns into other columns that are more usable

--Check results
Select *
From Data_Cleaning.dbo.NashvilleHousing