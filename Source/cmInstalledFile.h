/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2014 Kitware, Inc., Insight Software Consortium

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/
#ifndef cmInstalledFile_h
#define cmInstalledFile_h

#include "cmPropertyMap.h"

/** \class cmInstalledFile
 * \brief Represents a file intended for installation.
 *
 * cmInstalledFile represents a file intended for installation.
 */
class cmInstalledFile
{
public:
  void SetProperty(const std::string& prop, const char *value);
  void AppendProperty(const std::string& prop,
                      const char* value,bool asString=false);
  const char *GetProperty(const std::string& prop) const;
  bool GetPropertyAsBool(const std::string& prop) const;

  void SetName(const std::string& name);
  std::string const& GetName() const;

  cmPropertyMap const& GetProperties() const { return this->Properties; }

private:
  std::string Name;
  cmPropertyMap Properties;
};

#endif
