/*
Cleaning Data in SQL Queries
*/

select * from [Data Analytics using SQL]..Housing

-- Standardize Date Format
select SaleDate,convert(Date,SaleDate) from [Data Analytics using SQL]..Housing

Alter table [Data Analytics using SQL]..Housing
add SaleDateConvered Date

update [Data Analytics using SQL]..Housing
set SaleDateConvered=convert(Date,SaleDate)

select SaleDateConvered from [Data Analytics using SQL]..Housing

-- Populate Property Address data

select *  from [Data Analytics using SQL]..Housing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress , b.ParcelID,b.PropertyAddress
from [Data Analytics using SQL]..Housing a
join [Data Analytics using SQL]..Housing b
on  a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from [Data Analytics using SQL]..Housing a
join [Data Analytics using SQL]..Housing b
on  a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select PropertyAddress from [Data Analytics using SQL]..Housing

-- Breaking out Address into Individual Columns (Address, City, State)
select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from [Data Analytics using SQL]..Housing

Alter table [Data Analytics using SQL]..Housing
add PropertySplitAddress Nvarchar(255);

Update [Data Analytics using SQL]..Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter table [Data Analytics using SQL]..Housing
add PropertySplitCity Nvarchar(255);

update [Data Analytics using SQL]..Housing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

 select * from [Data Analytics using SQL]..Housing

 -- Splitting owner address

select OwnerAddress from [Data Analytics using SQL]..Housing
where OwnerAddress is not null

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from [Data Analytics using SQL]..Housing

ALTER TABLE [Data Analytics using SQL]..Housing
Add OwnerSplitAddress Nvarchar(255);

Update [Data Analytics using SQL]..Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Data Analytics using SQL]..Housing
Add OwnerSplitCity Nvarchar(255);

Update [Data Analytics using SQL]..Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Data Analytics using SQL]..Housing
Add OwnerSplitState Nvarchar(255);

Update [Data Analytics using SQL]..Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select * from [Data Analytics using SQL]..Housing

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from [Data Analytics using SQL]..Housing
group by SoldAsVacant
order by SoldAsVacant 

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from [Data Analytics using SQL]..Housing

update [Data Analytics using SQL]..Housing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end


select SoldAsVacant	 from [Data Analytics using SQL]..Housing

 -- Remove Duplicates
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

From [Data Analytics using SQL]..Housing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Delete Unused Columns

alter table [Data Analytics using SQL]..Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate