/*     Cleaning Data in SQL Queries   

Functions and Concepts used here :
• ALTER and UPDATE 
• JOINing Tables
• SUBSTRING()
• PARSENAME() along with REPLACE()
• CASE
• Identifying duplicates 
• Droping Columns
*/


--Standardizing date format
select saledate
from Portfolio_Projects..NashvilleHousing

alter table nashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

select SaleDateConverted
from Portfolio_Projects..NashvilleHousing



--Populate Property Address data

select *
from Portfolio_Projects..NashvilleHousing
where PropertyAddress is null
order by ParcelID

--using ISNULL()
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Projects..NashvilleHousing a
join Portfolio_Projects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
order by a.ParcelID

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Projects..NashvilleHousing a
join Portfolio_Projects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
/*Note : The second to last query was performed first that gave a result of 35 rows.Then 
the last query was performed to fill all the null values which will result in the second to 
last query not give any results anymore. */



--Breaking Address into individual columns (Address, City, State)

--using SUBSTRING()
select PropertyAddress
from Portfolio_Projects..NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress)) as Address1
from Portfolio_Projects..NashvilleHousing

alter table nashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table nashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress))

select *
from Portfolio_Projects..NashvilleHousing



--Breaking owner address into parts using PARSENAME()

--parsename() looks for period's so replacing commas by periods.
select ownerAddress 
from Portfolio_Projects..NashvilleHousing

select 
parsename(replace(ownerAddress,',','.'),1),
parsename(replace(ownerAddress,',','.'),2), 
parsename(replace(ownerAddress,',','.'),3) 
from Portfolio_Projects..NashvilleHousing

alter table nashvilleHousing
add OwnerSplitAddress nvarchar(255)
update NashvilleHousing
set OwnerSplitAddress = parsename(replace(ownerAddress,',','.'),3)

alter table nashvilleHousing
add OwnerSplitCity nvarchar(255)
update NashvilleHousing
set OwnerSplitCity = parsename(replace(ownerAddress,',','.'),2)

alter table nashvilleHousing
add OwnerSplitState nvarchar(255)
update NashvilleHousing
set OwnerSplitState = parsename(replace(ownerAddress,',','.'),1)

select *
from Portfolio_Projects..NashvilleHousing



--Changing Y and N to yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio_Projects..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	 WHEN SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END
from Portfolio_Projects..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	 WHEN SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END

/* 
The first set of query displays a table countaning 'Yes','No','Y','N'. 
After the update statement it will have only 'Yes' and 'No'.
*/



--Removing Duplicates

WITH rownumCTE as(
select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 Saleprice,
				 Saledate,
				 LegalReference
				 order by 
				 uniqueid
				 ) as row_num
from Portfolio_Projects..NashvilleHousing
--where row_num > 1
--order by ParcelID
)
select *
from rownumcte
where row_num > 1
order by PropertyAddress



--deleting the rows

WITH rownumCTE as(
select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 Saleprice,
				 Saledate,
				 LegalReference
				 order by 
				 uniqueid
				 ) as row_num
from Portfolio_Projects..NashvilleHousing
--where row_num > 1
--order by ParcelID
)
delete
from rownumcte
where row_num > 1



--Deleting Unused Columns

select *
from Portfolio_Projects..NashvilleHousing

alter table Portfolio_Projects..NashvilleHousing
drop column owneraddress
