--Cleaning data in SQL

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



-----------------------------
-- Standardize Date Format --
-----------------------------
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

SELECT SaleDate FROM PortfolioProject.dbo.NashvilleHousing --For some reason this did not work



ALTER TABLE PortfolioProject.dbo.NashvilleHousing  -- Let's try this method
ADD SaleDateConverted Date

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted FROM PortfolioProject.dbo.NashvilleHousing -- This method converted date successfully.



------------------------------------
-- Populate PropertyAddress data --
------------------------------------

SELECT A.PropertyAddress, A.ParcelID, B.PropertyAddress, B.ParcelID
FROM PortfolioProject.dbo.NashvilleHousing as A
JOIN PortfolioProject.dbo.NashvilleHousing as B
ON A.ParcelID = B.ParcelID AND A.UniqueID != B.UniqueID
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as A
JOIN PortfolioProject.dbo.NashvilleHousing as B
ON A.ParcelID = B.ParcelID AND A.UniqueID != B.UniqueID
WHERE A.PropertyAddress IS NULL

--------------------------------------------------------------------------
-- Breaking out Address into Individual Columns ( Address, City, State) --
--------------------------------------------------------------------------
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

--Looking at the PropertyAddress, I decide ',' will be our deliminator
SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 2,LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

-- Adding two split columns to the address
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)
UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..NashvilleHousing


--------------------------------
-- Changing the Owner Address --
--------------------------------
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS OwnerSplitState,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS OwnerSplitAddress
FROM PortfolioProject..NashvilleHousing;

-- Adding three split columns to the OwnerAddress
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject..NashvilleHousing;



---------------------------------------------------------
-- Change Y and N to Yes and No in SoldAsVacant column --
---------------------------------------------------------

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant; -- We got 4 distinct values: N, No, Y, Yes

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
						END

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant; -- Now we got 2 distinct values 'Yes', 'No'


-----------------------
-- Remove Duplicates --
-----------------------
WITH RowNumCTE AS 
(
SELECT * , ROW_NUMBER() OVER
			(
			PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID
			) row_num

FROM PortfolioProject..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-------------------------
-- Delete Unused Items --
-------------------------

SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict