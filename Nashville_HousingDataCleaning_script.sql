
-- Data cleaning 

select * 
from Portfolio..NashvilleHousing

---------------------------------------------------------------------------------------------------

-- Fixing the date format

select SaleDate, convert(date, SaleDate)
from Portfolio..NashvilleHousing

Update NashvilleHousing
SET SaleDate = convert(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = convert(date, SaleDate)

---------------------------------------------------

-- Populate the property address (filling the null address values)
-- joining the table on itslef based the ParcelID which is repeated in the table, so we used that to fill the null address 
-- based on the ParcelId

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Portfolio..NashvilleHousing a 
join Portfolio..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 And a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null


 Update a
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 from Portfolio..NashvilleHousing a 
join Portfolio..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 And a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------

-- Split the city from the property address

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertyAddress1 nvarchar(225)

Update NashvilleHousing
SET PropertyAddress1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertyCity nvarchar(225)

Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


Select PropertyAddress1, PropertyCity
From NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------

-- Split the city and state from the owner address

Select ownerAddress
From NashvilleHousing

Select 
PARSENAME(replace(ownerAddress,',', '.'), 3),
PARSENAME(replace(ownerAddress,',', '.'), 2),
PARSENAME(replace(ownerAddress,',', '.'), 1)
From NashvilleHousing

ALTER TABLE NAshvilleHousing
Add OwnerAddress1 nvarchar(225)

ALTER TABLE NAshvilleHousing
Add OwnerCity nvarchar(225)

ALTER TABLE NAshvilleHousing
Add OwnerState nvarchar(225)

Update NashvilleHousing
SET OwnerAddress1 = PARSENAME(replace(ownerAddress,',', '.'), 3), 
     OwnerCity =PARSENAME(replace(ownerAddress,',', '.'), 2),
     OwnerState = PARSENAME(replace(ownerAddress,',', '.'), 1)


Select OwnerAddress1, OwnerCity, OwnerState
From NashvilleHousing

----------------------------------------------------------------------------------------------

-- change the 'Y', 'N', to 'Yes', 'No' 

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
Group By SoldAsVacant
order by 1

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'YES'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' then 'YES'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

------------------------------------------------------------------------------------------------------------------------

-- Remove Duplication
WITH DuplRow  AS( 
Select * 
     , ROW_NUMBER() OVER (
       PARTITION BY ParcelID,
	                PropertyAddress,
				    SalePrice,
				    SaleDate,
				    LegalReference
					ORDER BY UniqueID) row_num
From NashvilleHousing
)
Delete
FROM DuplRow
Where row_num > 1



