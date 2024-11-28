--Data Cleaning

select *from PortfolioProject..NashvilleHousing

--Standarize Date Format

select cast(SaleDate as date)  from PortfolioProject..NashvilleHousing
update NashvilleHousing
set SaleDate=cast(SaleDate as Date)

Alter table NashvilleHousing
add  SaleDateConverted date;
go
update NashvilleHousing
set SaleDateConverted=cast(SaleDate as Date)

--Populate address data

select a.PropertyAddress,a.ParcelID ,b.PropertyAddress,b.ParcelID from PortfolioProject..NashvilleHousing a 
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a 
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
 

 --Breaking out address into individual columns(address,city,state)

 --propertyaddress
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as city
from PortfolioProject..NashvilleHousing 

Alter table NashvilleHousing
add  PropertySplitAddress nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
go
 
Alter table NashvilleHousing
add  PropertySplitCity nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--owneraddress
select PARSENAME(replace(OwnerAddress,',','.'),3),
 PARSENAME(replace(OwnerAddress,',','.'),2),
  PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
add  OwnerSplitCity nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
add  OwnerSplitState nvarchar(255)
go

update PortfolioProject..NashvilleHousing
set OwnerSplitState=  PARSENAME(replace(OwnerAddress,',','.'),1)

--change y and N to yes and no in 'sold as vacant' field

select SoldAsVacant, 
case 
when SoldAsVacant= 'Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant 
end
from  PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant=case 
when SoldAsVacant= 'Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant 
end

select distinct(SoldAsVacant)
from  PortfolioProject..NashvilleHousing

--Removing Duplicates

with RowNumCTE as
( 
select *,ROW_NUMBER()over (partition by ParcelId,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueID) row_num
from  PortfolioProject..NashvilleHousing
)

select * from RowNumCTE where row_num>1

--Delete unused data 

alter table PortfolioProject..NashvilleHousing
drop column PropertyAddress,OwnerAddress,TaxDistrict
alter table PortfolioProject..NashvilleHousing
drop column SaleDate





