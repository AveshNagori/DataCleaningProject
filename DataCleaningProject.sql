use PortfolioProject;

Select * from 
PortfolioProject..NashvilleHousing


--Standarize Date format

Select Sale_Date,CONVERT(date,saledate) 
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,saledate) 

Alter table NashvilleHousing
Add Sale_Date Date;

Update NashvilleHousing
Set Sale_Date = CONVERT(date,saledate) 


--Populate Property Address Data

Select * from 
PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID 
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID 
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out Address into Individual Columns(Address,City,State)


Select PARSENAME(Replace(PropertyAddress,',','.'),2),
PARSENAME(Replace(PropertyAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add Property_Address varchar(222)

Alter table NashvilleHousing
Add Property_City varchar(222)

Update NashvilleHousing
Set Property_City = PARSENAME(Replace(PropertyAddress,',','.'),2)

Update NashvilleHousing
Set Property_City = PARSENAME(Replace(PropertyAddress,',','.'),1)


Select PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing
where owneraddress is not null


Alter table NashvilleHousing
Add Owner_Address varchar(222)

Alter table NashvilleHousing
Add Owner_City varchar(222)

Alter table NashvilleHousing
Add Owner_State varchar(222)

Update NashvilleHousing
Set Owner_Address = PARSENAME(Replace(OwnerAddress,',','.'),3)

Update NashvilleHousing
Set Owner_City = PARSENAME(Replace(OwnerAddress,',','.'),2)

Update NashvilleHousing
Set Owner_State = PARSENAME(Replace(OwnerAddress,',','.'),1)



--Change 'Y' And 'N' to 'Yes' And 'No' in "SoldAsVacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant) as Count_
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant 
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End



--Remove Duplicates

With RowNumCTE as
(
Select *,
	Row_Number() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
)
DELETE
from RowNumCTE 
where row_num>1



--Delete Unused Columns

Alter Table NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate