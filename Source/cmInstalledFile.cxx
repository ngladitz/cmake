/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2014 Kitware, Inc., Insight Software Consortium

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/
#include "cmInstalledFile.h"
#include "cmSystemTools.h"

//----------------------------------------------------------------------------
void cmInstalledFile::SetName(const std::string& name)
{
  this->Name = name;
}

//----------------------------------------------------------------------------
std::string const& cmInstalledFile::GetName() const
{
  return this->Name;
}

//----------------------------------------------------------------------------
void cmInstalledFile::SetProperty(const std::string& prop, const char* value)
{
  this->Properties.SetProperty(prop, value, cmProperty::INSTALL);
}

//----------------------------------------------------------------------------
void cmInstalledFile::AppendProperty(const std::string& prop,
  const char* value, bool asString)
{
  this->Properties.AppendProperty(prop, value, cmProperty::INSTALL, asString);
}

//----------------------------------------------------------------------------
const char* cmInstalledFile::GetProperty(const std::string& prop) const
{
  bool chain = false;
  const char *retVal =
    this->Properties.GetPropertyValue(prop, cmProperty::INSTALL, chain);

  return retVal;
}

//----------------------------------------------------------------------------
bool cmInstalledFile::GetPropertyAsBool(const std::string& prop) const
{
  return cmSystemTools::IsOn(this->GetProperty(prop));
}
