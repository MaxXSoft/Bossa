#!/usr/bin/env python3

'''
A FIRRTL 'BlackBoxResourceAnno' resolver.
'''

import json
from typing import Dict, List, TextIO, Set, Optional
from dataclasses import dataclass
from os import walk, path
from shutil import copyfile
import argparse


@dataclass(frozen=True)
class ResourceInfo:
  '''
  Resource information.
  '''

  project: Optional[str]
  src_type: str
  path: str

  def __str__(self) -> str:
    p = f'{self.src_type}:{self.path}'
    return f'{self.project}:{p}' if self.project else p

  def __repr__(self) -> str:
    return self.__str__()


'''
Resource directories.
'''
ResourceDirs = Dict[str, List[str]]


def get_resources(f: TextIO) -> Set[str]:
  '''
  Gets the set of resource ids from the specific JSON file.
  '''
  resources = set()
  for i in json.load(f):
    if i['class'] == 'firrtl.transforms.BlackBoxResourceAnno':
      resources.add(i['resourceId'])
  return resources


def get_resource_infos(resources: Set[str]) -> List[ResourceInfo]:
  '''
  Gets parsed resource information from the specific resource id set.
  '''
  results = []
  for res in resources:
    if 'csrc' in res:
      src_type = 'csrc'
      rs = res.split('csrc')
    elif 'vsrc' in res:
      src_type = 'vsrc'
      rs = res.split('vsrc')
    else:
      raise RuntimeError(f'invalid resource id "{res}"')
    project = rs[0].strip('/')
    if not project:
      project = None
    results.append(ResourceInfo(project, src_type, rs[1].lstrip('/')))
  return results


def find_resources_dirs(root: str) -> Dict[str, List[str]]:
  '''
  Finds resources directories in the specific root directory.
  '''
  results = {'csrc': [], 'vsrc': []}
  for dir, _, _ in walk(root):
    if f'{path.sep}.git' not in dir and f'{path.sep}resources' in dir:
      if dir.endswith(f'{path.sep}csrc'):
        results['csrc'].append(dir)
      elif dir.endswith(f'{path.sep}vsrc'):
        results['vsrc'].append(dir)
  return results


def get_resource_files(infos: List[ResourceInfo], dirs: ResourceDirs) -> Set[str]:
  '''
  Gets full paths of all resources.
  '''
  results = set()
  for info in infos:
    # get target directories
    targets = dirs[info.src_type]
    if info.project:
      targets = list(filter(lambda d: info.project in d, targets))
    if not len(targets):
      raise RuntimeError(f'no target directory found for resource "{info}"')
    # find in target directories
    found = False
    for t in targets:
      file = path.realpath(path.join(t, info.path))
      if path.exists(file):
        if found:
          raise RuntimeError(
              f'found multiple target files for resource "{info}"')
        if file in results:
          raise RuntimeError(
              f'found multiple resources corresponding to file "{file}"')
        results.add(file)
        found = True
    if not found:
      raise RuntimeError(f'target file not found for resource "{info}"')
  return results


def copy_to_cur_dir(files: Set[str], cur_dir: str) -> Set[str]:
  '''
  Copies the specific files to the current directory.

  Returns paths to copied files.
  '''
  results = set()
  for file in files:
    copied = path.realpath(path.join(cur_dir, path.basename(file)))
    copyfile(file, copied)
    results.add(copied)
  return results


if __name__ == '__main__':
  # initialize argument parser
  parser = argparse.ArgumentParser(
      description='A FIRRTL `BlackBoxResourceAnno` resolver.')
  parser.add_argument('anno', metavar='ANNO',
                      help='the input FIRRTL annotation file')
  parser.add_argument('-r', '--root', default=path.curdir, type=str,
                      help='the root directory of the Scala project')
  parser.add_argument('-c', '--copy', default='', type=str,
                      help='copies collected resource files to a specific directory')
  parser.add_argument('-f', '--dotf', default='', type=str,
                      help='the output dot f file (default to stdout)')

  # parse arguments
  args = parser.parse_args()

  # collect resource files
  with open(args.anno) as f:
    infos = get_resource_infos(get_resources(f))
    dirs = find_resources_dirs(args.root)
    files = get_resource_files(infos, dirs)
    if args.copy:
      files = copy_to_cur_dir(files, args.copy)

  # generate dot f file
  dotf = '\n'.join(files)
  if args.dotf:
    with open(args.dotf, 'w') as f:
      f.write(dotf + '\n')
  else:
    print(dotf)
