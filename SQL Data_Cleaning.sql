

--HOUSING DATASET CLEANING

select * from Housingdata

-- To start with, lets change the date format to datetime
select SaleDate, convert(date,SaleDate) from Housingdata

Alter Table Housingdata 
add New_SalesDate date

Update Housingdata
set New_SalesDate= convert(date,SaleDate) 



--In the data, there are null values found in the propertyaddress column, 
--and we can fill that in with the ParcelID since repeated IDs have the same address
--Lets do that by joining the table to itself to extract the null values in propertyAddress column

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from Housingdata a
join Housingdata b on a.ParcelID = b.ParcelID 
and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from Housingdata a
join Housingdata b on a.ParcelID = b.ParcelID 
and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

--Taking out the first values in the PropertyAddress column before the delimiter


 SELECT LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) [Address],
       RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) [City] 
FROM Housingdata

-- We will then update and add the two columns to our table
Alter Table Housingdata 
add Address nvarchar (255)

Alter Table Housingdata 
add City nvarchar (255)

Update Housingdata
set Address= LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1)

Update Housingdata
set City=RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))

--We will split the OWNER ADDRESS column by removing the delimiter to extracts the State,Address and Owner's name

select PARSENAME(Replace(OwnerAddress,',', '.'), 3) Owners_Address
, PARSENAME(Replace(OwnerAddress,',', '.'), 2) Owners_Name
, PARSENAME(Replace(OwnerAddress,',', '.'), 1) Owners_State
from Housingdata

--select OwnerAddress from Housingdata;
-- I mistakenly created null columns, lets drop them
Alter table Housingdata
drop column if exists Owners_Address, Owners_Name, Owners_State; 

--Lets update and add the new columns to our data
Alter Table Housingdata 
add Owners_Address nvarchar (255);

Update Housingdata
set Owners_Address = PARSENAME(Replace(OwnerAddress,',', '.'), 3) 


Alter Table Housingdata 
add Owners_Name nvarchar (255);

Update Housingdata
set Owners_Name= PARSENAME(Replace(OwnerAddress,',', '.'), 2)

Alter Table Housingdata 
add Owners_State  nvarchar (255)

Update Housingdata
set Owners_State = PARSENAME(Replace(OwnerAddress,',', '.'), 1) 

select * from Housingdata

--Change Y and N to YES,NO in the SoldAsVacant column

select distinct (SoldAsVacant),count (SoldAsVacant)
from Housingdata
group by SoldAsVacant
order by 2

Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM Housingdata

-- As usual, we need to update our table with the new values
Update Housingdata
set SoldAsvacant= CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


--Removing Duplicates

WITH Row_num_CTE As(
select *, ROW_NUMBER()
		OVER (PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		order by UniqueID) row_num
from Housingdata

)

select * from Row_num_CTE
where row_num >1
order by PropertyAddress


--Lets delete the duplicates

WITH Row_num_CTE As(
select *, ROW_NUMBER()
		OVER (PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		order by UniqueID) row_num
from Housingdata
)
Delete from Row_num_CTE
where row_num >1

--DELETE UNUSED COLUMNS
select * from Housingdata

Alter table Housingdata
Drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict



--We have come to the end of our data cleaning 


