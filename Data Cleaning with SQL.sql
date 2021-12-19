/*

Cleaning data in SQL Queries

*/

Select *
From PortofolioProject.dbo.NashvilleHousing

-- Standardize Data Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortofolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data

Select *
From PortofolioProject..NashvilleHousing
-- Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into individual Columns (Address, City, State)
Select PropertyAddress
From PortofolioProject..NashvilleHousing
-- Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortofolioProject..NashvilleHousing


Select OwnerAddress
From PortofolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortofolioProject..NashvilleHousing


-- Change Y and N to Yes and No in sold as vacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortofolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	else SoldAsVacant
	END
From PortofolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	else SoldAsVacant
	END


-- Remove Duplicates

with RowNumCTE As(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From PortofolioProject..NashvilleHousing
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress


## delete duplicate youtube alex 3/5


-- Delete Unused Columns

Select *
From PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortofolioProject..NashvilleHousing
Drop COLUMN SaleDate






























