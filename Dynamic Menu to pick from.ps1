# Made by Bwilliamson
#
# Feel free to use this for whatever.
#
# Purpose:
# Dynamically create a menu of options, keep adding items to the 'searchbase' until user is done.
# This is intended for OU's, but I suppose any list of returned objects could be substituted. 
# I may still add an option to 'add all'

# This script MUST HAVE the activedirectory module to work with get-adobject. This module is obtained with RSAT on most systems. 
import-module activedirectory

#Initialize the vars and the array. Searchbase won't need to be in a regular PS windows, but in ISE it will hold it's value between runs.
$searchcontinue = "null"
$searchbase = @()

#If the user hasn't selected one of these, keep doing this loop
while ("yes","null","y" -contains $searchcontinue)
{
  #Set up our menu hash table, and our hash table of options to pick from. In this case, from AD-Objects.  
  $menu = @{}
  $OUhash = @{}
  #The wehre-object here seems like it would only evaluate one item due to the singulare '.name', but really it evaluates every item that goes through the pipe.
  #This is why we're using '-notcontains' rather than '-ne' 
  $OUhash = Get-ADObject -Filter 'ObjectClass -eq "organizationalunit"' | Where-Object { $searchbase.Name -notcontains $_.Name } | Select-Object Name,DistinguishedName

  #Force the hash to evaluate as an array- because if we don't, and there's only one choice, '.count' doesn't return anything. 
  #Also, make sure that there's items left to be picked. If you pick the last item, you don't want to see an empty list to choose from.
  if (@($OUhash).count -ge 1) 
  {

    Write-Host "The following are available OUs to search, and that you have not already selected." `n
      #Before the loop set $i to 1. Every loop evaluate, and make sure $i isn't greater than the number of items we have. After every loop, incriment $i. 
      for ($i = 1; $i -le @($OUhash).count; $i++) 
      {
        #We need to subtract 1 from $i for the proper hash value- hashes start at 0. 
        Write-Host "$i. $($OUhash[$i-1].name)"
        #I suppose we could also do $menu += rather than $menu.add, but .add has less overhead, and works with empty hash tables. This would fail with an array (@())
        $menu.Add($i,($OUhash[$i - 1].Name))
      }

    # Ask user for first choice, and make it an int. 
    [int]$ans = Read-Host `n 'Enter selection'

    # Sanitize the answer. Regex to match any 1 to 3 digit number. Make sure it's in scope, and not zero. Since $ans is [int]$ans- entering nothing will turn it into a zero.
      while ($ans -notmatch '\d{1,3}' -or $ans -gt @($OUhash).count -or $ans -eq 0)
      {
       [int]$ans = Read-Host `n 'Enter selection'
      }
    #Again, subtract 1 to get the proper index.
    $searchbase += $OUhash[$ans - 1]
  
  #Show the user what he's picked, and ask if they want to continue adding more. 
  Write-Host `n 'You have added ' -NoNewline
  Write-Host ($OUhash[$ans - 1].Name) -fore yellow -NoNewline
  Write-Host ' OU to the searchbase.'
  Write-Host `n 'Add another OU to searchbase?' -NoNewline
  Write-Host ' Yes or No' -ForegroundColor Yellow `n`n

  $searchcontinue = Read-Host
    #Added y and n to this, as well as the while up top. For faster input.
    while ("yes","no","y","n" -notcontains $searchcontinue)
    {
      $searchcontinue = Read-Host "Yes or No"
    }
  #If the user has no choices left- let them know, and break the loop by setting searchcontinue silently to no.
  }
  else 
  {
   write-host `r`n "Nothing in OU results! Exiting the loop..`r`n" -fore Yellow
   $searchcontinue = "no"   
  }
}

  #This silly output stuff can be stripped for your scripts. It's really just for debugging/showing what we ended up with.
  #Assuming they picked more than one- show them a table. Otherwise, output the single hash item in a few ways. For OU's it will be the Name and the DN. 
  if ( $searchbase.count -gt 1) 
  {
    Write-Host "You've Selected the following OUs: `r`n  "
    $searchbase | FT
  } 
  else
  {
  Write-Host "You've Selected.. " -nonewline
  write-host $searchbase -fore Yellow -nonewline
  write-host "`r`nMore easily read as the OU:" -NoNewline
  write-host $searchbase.name -fore yellow -nonewline
  write-host "`r`nWith the DN of:" -NoNewline
  write-host $searchbase.Distinguishedname -fore yellow
  }