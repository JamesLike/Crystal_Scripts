from __future__ import division
from mmtbx import utils
import mmtbx.f_model
from iotbx.option_parser import iotbx_option_parser
from iotbx.pdb import combine_unique_pdb_files
from iotbx import reflection_file_reader
from iotbx import reflection_file_utils
import iotbx.file_reader
import iotbx.symmetry
import iotbx.phil
from cctbx.array_family import flex
import iotbx.pdb
from cctbx import miller
from libtbx.str_utils import format_value
from libtbx.utils import Sorry, null_out
from libtbx import adopt_init_args
from libtbx import runtime_utils
import libtbx.callbacks # import dependency
from cStringIO import StringIO
import os
import sys
import mmtbx.model

phase_source = '/mnt/data4/XFEL/LR23/DED_tests/dat/Dark.pdb'
f_obs_1_file_name = 'a/ligh_old_truncate.mtz'
f_obs_2_file_name = 'a/dark_old_truncate.mtz' 

def multiscale(self, other, reflections_per_bin = None):
  if(reflections_per_bin is None):
    reflections_per_bin = other.indices().size()
  assert self.indices().all_eq(other.indices())
  assert self.is_similar_symmetry(other)
  self.setup_binner(reflections_per_bin = reflections_per_bin)
  other.use_binning_of(self)
  scale = flex.double(self.indices().size(),-1)
  for i_bin in self.binner().range_used():
    sel = self.binner().selection(i_bin)
    f1  = self.select(sel)
    f2  = other.select(sel)
    scale_ = 1.0
    den = flex.sum(flex.abs(f2.data())*flex.abs(f2.data()))
    if(den != 0):
      scale_ = flex.sum(flex.abs(f1.data())*flex.abs(f2.data())) / den
    scale.set_selected(sel, scale_)
  assert (scale > 0).count(True) == scale.size()
  return other.array(data = other.data()*scale)

parameters=utils.data_and_flags_master_params().extract()

print(parameters.labels)


