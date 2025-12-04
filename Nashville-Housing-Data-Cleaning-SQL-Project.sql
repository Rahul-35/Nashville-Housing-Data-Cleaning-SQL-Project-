select * from PortfolioProject2.dbo.NashvilleHousing

--- Standarize the date format

select SaleDate , CONVERT(date,SaleDate)
from PortfolioProject2.dbo.NashvilleHousing

Alter table PortfolioProject2..NashvilleHousing
add SalesDateConverted Date

update PortfolioProject2..NashvilleHousing
set SalesDateConverted=CONVERT(date,SaleDate)

----------------------------------------------------------

--- Populate Property address data

select *
from PortfolioProject2..NashvilleHousing
order by ParcelID

-- In order to populate missing property addresses 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject2..NashvilleHousing a
join PortfolioProject2..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is not null

-- finding the records with null propertyaddress first and then updating with real address
Update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject2..NashvilleHousing a
join PortfolioProject2..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-- splitting the address into segments ( city and state)

select PropertyAddress
from PortfolioProject2..NashvilleHousing
--order by ParcelID

select PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as State
from PortfolioProject2..NashvilleHousing

Alter Table PortfolioProject2..NashvilleHousing
add PropertySplitAddress nvarchar(255)

Alter Table PortfolioProject2..NashvilleHousing
add PropertyCity nvarchar(255)

Update PortfolioProject2..NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Update PortfolioProject2..NashvilleHousing
set PropertyCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select PropertySplitAddress, PropertyCity
from PortfolioProject2..NashvilleHousing


select OwnerAddress
from PortfolioProject2..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
from PortfolioProject2..NashvilleHousing


Alter Table PortfolioProject2..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

Alter Table PortfolioProject2..NashvilleHousing
add  OwnerSplitCity nvarchar(255)

Alter Table PortfolioProject2..NashvilleHousing
add  OwnerSplitState nvarchar(255)


update PortfolioProject2..NashvilleHousing
set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress, ',','.'),3)

update PortfolioProject2..NashvilleHousing
set OwnerSplitCity=PARSENAME(Replace(OwnerAddress, ',','.'),2)

update PortfolioProject2..NashvilleHousing
set OwnerSplitState=PARSENAME(Replace(OwnerAddress, ',','.'),1)


select * from PortfolioProject2..NashvilleHousing


------ Change Y and N to Yes and No in "Sold as vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject2..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject2..NashvilleHousing


update PortfolioProject2..NashvilleHousing
set SoldAsVacant= 
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end


	--- Remove Duplicates
with RowNumCTE as (
	select *,
	ROW_NUMBER() OVER(
	Partition By ParcelID,
				 PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By UniqueID
	) as row_num
from PortfolioProject2..NashvilleHousing
)

select * from RowNumCTE
where row_num>1
order by PropertyAddress

--DELETE 
--from RowNumCTE 
--where row_num>1


--------------- Delete Unused Columns

select * 
from PortfolioProject2..NashvilleHousing


alter table PortfolioProject2..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress