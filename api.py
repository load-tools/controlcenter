import logging
import yaml
from StringIO import StringIO

from werkzeug.exceptions import BadRequest

from yandextank.config_converter.converter import ConversionError
from yandextank.core.consoleworker import load_core_base_cfg, load_local_base_cfgs, convert_ini
from yandextank.validator.validator import TankConfig


def response(full_cfg, errors):
    return {'config': full_cfg, 'errors': errors}


def validate_config(config, fmt):

    if fmt == 'ini':
        stream = StringIO(str(config.read()))
        config.close()
        try:
            cfg = convert_ini(stream)
            tank_config = TankConfig([load_core_base_cfg()] +
                                     load_local_base_cfgs() +
                                     [cfg])
            return response(tank_config.raw_config_dict, tank_config.errors())
        except ConversionError as e:
            return response({}, [e.message])
        except Exception:
            logging.error('Exception during reading Tank config', exc_info=True)
            raise BadRequest()
    else:
        try:
            cfg = yaml.load(config)
            config.close()
            tank_config = TankConfig([load_core_base_cfg()] +
                                     load_local_base_cfgs() +
                                     [cfg])
            return response(tank_config.raw_config_dict, tank_config.errors())
        except Exception:
            logging.error('Exception during reading Tank config', exc_info=True)
            raise BadRequest()


def validate_config_json(config):
    try:
        tank_config = TankConfig([load_core_base_cfg()] +
                                 load_local_base_cfgs() +
                                 [config])
        return response(tank_config.raw_config_dict, tank_config.errors())
    except Exception:
        logging.error('Exception during reading Tank config', exc_info=True)
        raise BadRequest()
