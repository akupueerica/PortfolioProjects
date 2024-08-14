/*

Cleaning Data in SQL Queries

*/

Select *
From [Portfolio Project]..NashvilleHousing


--Standardize Date Format (added a new column(saledateconverted) to convert datetime values to date, updated it with the converted date vales and dropped old column(SaleDate) containing the datetime)


alter table [Portfolio Project]..NashvilleHousing
add SaleDateconverted date

update [Portfolio Project]..NashvilleHousing
set SaleDateconverted  = CONVERT(date, SaleDate)

alter table [Portfolio Project]..NashvilleHousing
drop column SaleDate


-- Populate Property Address data (made a self join statement to split the table into two similar tables, one(a) with propertyaddress(PA) as null and the other(b) with PA addresses, then updated table a with PA addresses from table b)


select *
From [Portfolio Project]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull( a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
join [Portfolio Project]..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull( a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
join [Portfolio Project]..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out the PropertyAddress into two addresses which were then populated into two newly created columns of propertysplitAddress and propertysplitCity, then PropertyAddress column dropped 

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing

select substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as address,
       substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as address
from [Portfolio Project]..NashvilleHousing

alter table [Portfolio Project]..NashvilleHousing
add propertysplitAddress nvarchar(255)

update [Portfolio Project]..NashvilleHousing
set propertysplitAddress  = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

alter table [Portfolio Project]..NashvilleHousing
add propertysplitCity nvarchar(255)

update [Portfolio Project]..NashvilleHousing
set propertysplitCity  = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

alter table [Portfolio Project]..NashvilleHousing
drop column PropertyAddress


--Breaking out the OwnerAddress into 3 parts which were populated into 3 newly created columns, and the owneraddress column dropped

Select OwnerAddress
From [Portfolio Project]..NashvilleHousing

select parsename(replace(OwnerAddress, ',', '.'), 3),
       parsename(replace(OwnerAddress, ',', '.'), 2),
	   parsename(replace(OwnerAddress, ',', '.'), 1)
From [Portfolio Project]..NashvilleHousing

alter table [Portfolio Project]..NashvilleHousing
add OnwersplitAddress nvarchar(255)

update [Portfolio Project]..NashvilleHousing
set OnwersplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table [Portfolio Project]..NashvilleHousing
add OnwersplitCity nvarchar(255)

update [Portfolio Project]..NashvilleHousing
set OnwersplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table [Portfolio Project]..NashvilleHousing
add OnwersplitState nvarchar(255)

update [Portfolio Project]..NashvilleHousing
set OnwersplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

alter table [Portfolio Project]..NashvilleHousing
drop column OwnerAddress


--Changed Y and N to YES and NO in SoldAsVacant column

select distinct(SoldAsVacant),count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
    case when SoldAsVacant = 'Y' then 'Yes'
         when SoldAsVacant = 'N' then 'No'
	     else SoldAsVacant
	     end 
From [Portfolio Project]..NashvilleHousing


update [Portfolio Project]..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
	                    else SoldAsVacant
	                    end 


--Identified and Removed duplicates


select ParcelID, SalePrice, SaleDateconverted, LegalReference, count(*)
From [Portfolio Project]..NashvilleHousing
group by ParcelID, SalePrice, SaleDateconverted, LegalReference
having count (*) > 1

--OR

with duplicateCTE as (
select *,
row_number() over(partition by ParcelID,
                               SaleDateconverted,
							   LegalReference,
							   SalePrice
             order by ParcelID) as row_num
From [Portfolio Project]..NashvilleHousing
)
delete
from duplicateCTE
where row_num > 1

