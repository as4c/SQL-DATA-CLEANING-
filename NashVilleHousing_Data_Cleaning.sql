

SELECT * 
FROM DataCleaning..NashvilleHousing;

---------------------------------------------------------------------------------------------------------------------------------

-- STANDARDRIZE DATE FORMAT
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM DataCleaning..NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM DataCleaning..NashvilleHousing;


-----------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data

SELECT *
FROM DataCleaning.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

SELECT * 
FROM NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID;
------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS,CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID;


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) AS PropertyStreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertyCity
FROM DataCleaning.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertyStreetAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 );

ALTER TABLE NashvilleHousing
ADD PropertyCityAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing;

SELECT OwnerAddress 
FROM NashvilleHousing;


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3); 

ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);
 
SELECT * 
FROM NashvilleHousing;

-------------------------------------------------------------------------------------------------------------------------

-- REPLACE YES TO 'Y' AND NO TO 'N' IN "SOLD AS VACANT" FIELD

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM DataCleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM DataCleaning.dbo.NashvilleHousing;


UPDATE DataCleaning.dbo.NashvilleHousing
SET SoldAsVacant = (
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
)

SELECT SoldAsVacant
FROM DataCleaning.dbo.NashvilleHousing;


---------------------------------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From DataCleaning.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM DataCleaning.dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM DataCleaning.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS

SELECT *
FROM DataCleaning.dbo.NashvilleHousing

ALTER TABLE DataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

