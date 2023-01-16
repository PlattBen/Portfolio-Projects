/*

Cleaning Data in SLQ Queries

*/
select*
From [Portfolio Project NHD].dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------

--Sale Date Format

select SaleDateConverted, CONVERT(date,SaleDate)
From [Portfolio Project NHD].dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert (date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date,SaleDate)

----------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From [Portfolio Project NHD].dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project NHD].dbo.NashvilleHousing a
JOIN [Portfolio Project NHD].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
--Where a.propertyaddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project NHD].dbo.NashvilleHousing a
JOIN [Portfolio Project NHD].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.propertyaddress is null

---------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project NHD].dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress)) as City
From [Portfolio Project NHD].dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) 

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
From [Portfolio Project NHD].dbo.NashvilleHousing




Select OwnerAddress
From [Portfolio Project NHD].dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
From [Portfolio Project NHD].dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)

Select *
From [Portfolio Project NHD].dbo.NashvilleHousing



-------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field"

select distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project NHD].dbo.NashvilleHousing
Group by SoldAsVacant
Order By 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From [Portfolio Project NHD].dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End


-----------------------------------------------------------------------------------------------------------------

--Remove Duplicates (usually not done to raw data)

With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order By
				UniqueID
				) row_num
From [Portfolio Project NHD].dbo.NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress




-------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From [Portfolio Project NHD].dbo.NashvilleHousing

Alter Table [Portfolio Project NHD].dbo.NashvilleHousing
Drop Column OwnerAddress, Taxdistrict, PropertyAddress, SaleDate

Alter Table [Portfolio Project NHD].dbo.NashvilleHousing
Drop Column SaleDate