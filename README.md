# 🏡 Nashville Housing Data Cleaning (SQL Project)

 This project demonstrates a complete end-to-end SQL data cleaning workflow performed on the Nashville Housing dataset inside a Microsoft SQL Server environment.
 The goal was to transform raw, inconsistent real-estate data into a clean and analysis-ready format.

# 📌 Project Objectives

 Standardize inconsistent date formats

 Populate missing property address information

 Split address fields into separate components

 Standardize categorical values

 Remove duplicate records

 Drop irrelevant or redundant columns

# 🛠️ Tech Stack

 SQL Server / SSMS

 T-SQL (Window Functions, Joins, CTEs, String Functions)

# 📂 Steps Performed
# 1️⃣ Standardize Date Format

## Converted the existing SaleDate column into a proper DATE type and stored it in a new column:

ALTER TABLE NashvilleHousing
ADD SalesDateConverted DATE;

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(DATE, SaleDate);

# 2️⃣ Populate Missing Property Addresses

## Used a self-join on ParcelID to fill NULL addresses from matching records:

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
  ON a.ParcelID = b.ParcelID 
 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

# 3️⃣ Split Property Address Into Components

## Split PropertyAddress into Address and City:

ALTER TABLE NashvilleHousing ADD PropertySplitAddress NVARCHAR(255);
ALTER TABLE NashvilleHousing ADD PropertyCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

# 4️⃣ Split Owner Address (Address, City, State)

Used PARSENAME() to extract 3 components:

ALTER TABLE NashvilleHousing ADD OwnerSplitAddress NVARCHAR(255);
ALTER TABLE NashvilleHousing ADD OwnerSplitCity NVARCHAR(255);
ALTER TABLE NashvilleHousing ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity    = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState   = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

# 5️⃣ Standardize “Sold As Vacant” Values

## Converted inconsistent values (Y, N) into full words:

UPDATE NashvilleHousing
SET SoldAsVacant =
  CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END;

# 6️⃣ Remove Duplicate Records

## Created a CTE using ROW_NUMBER() to identify duplicates:

WITH RowNumCTE AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ORDER BY UniqueID
         ) AS row_num
  FROM NashvilleHousing
)
-- DELETE FROM RowNumCTE WHERE row_num > 1;

# 7️⃣ Drop Unused Columns

## Removed redundant or cleaned-up fields:

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

# 📊 Outcome

## After running the full script:

✔ Cleaned, standardized date formats
✔ Complete and structured address fields
✔ Consistent categorical values
✔ Duplicate entries identified and removable
✔ Reduced table clutter by dropping unnecessary columns

# This prepares the Nashville Housing dataset for deeper analytics, visualization, BI dashboards, or machine learning workflows.
