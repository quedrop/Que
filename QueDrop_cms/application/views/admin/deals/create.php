<!-- Page header -->
<div class="page-header page-header-default">
    <div class="page-header-content">
        <div class="page-title">
            <h4>
                <span class="text-semibold"><?php _el('add_deal'); ?></span>
            </h4>
        </div>
    </div>
    <div class="breadcrumb-line">
        <ul class="breadcrumb">
            <li>
                <a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
            </li>
            <li>
                <a href="<?php echo base_url('admin/deals'); ?>"><?php _el('deals'); ?></a>
            </li>
            <li class="active"><?php _el('add'); ?></li>
        </ul>
    </div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
    <form action="<?php echo base_url('admin/deals/add'); ?>" id="dealform" method="POST">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
            <!-- Panel -->
            <div class="panel panel-flat">
                <!-- Panel heading -->
                <div class="panel-heading">
                    <div class="row">
                        <div class="col-md-10">
                            <h5 class="panel-title">
                                <strong><?php _el('deals'); ?></strong>
                            </h5>
                        </div>
                    </div>
                </div>
                <!-- /Panel heading -->
                <!-- Panel body -->
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('deal_name'); ?>:</label>
                                <input type="text" class="form-control" placeholder="<?php _el('deal_name'); ?>" id="deal_name" name="deal_name">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('deal_description'); ?>:</label>
                                <input type="text" class="form-control" placeholder="<?php _el('deal_description'); ?>" id="deal_description" name="deal_description">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('deal_value'); ?>:</label>
                                <input type="text" class="form-control" placeholder="<?php _el('deal_value'); ?>" id="deal_value" name="deal_value" class="deal_value">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('date_created'); ?>:</label>
                                <input type="date" class="form-control" placeholder="<?php _el('date_created'); ?>" id="date_created" name="date_created">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('date_expired'); ?>:</label>
                                <input type="date" class="form-control" placeholder="<?php _el('date_expired'); ?>" id="date_expired" name="date_expired">
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /Panel body -->	
            </div>
            <!-- /Panel -->
            </div>
        </div>
        <div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
            <button type="submit" class="btn btn-success" name="submit"><?php _el('save'); ?></button>
            <a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
        </div>
    </form>
</div>
<!-- /Content area -->

<script type="text/javascript">
var BASE_URL = "<?php echo base_url(); ?>";

$("#dealform").validate({
    rules: {
        deal_name: {
            required: true,
        },
        deal_description: {
            required: true,
        },
        deal_value: {
            required: true,
            number: true,
        },
        date_created: {
            required: true,
        },
        date_expired: {
            required: true,
        },
    },
    messages: {
        deal_name: {
            required:"<?php _el('please_enter_', _l('deal_name')) ?>",
        },
        deal_description: {
            required:"<?php _el('please_enter_', _l('deal_description')) ?>",
        },
        deal_value: {
            required:"<?php _el('please_enter_', _l('deal_value')) ?>",
        },
        date_created: {
            required:"<?php _el('please_select_', _l('date_created')) ?>",
        },
        date_expired: {
            required:"<?php _el('please_select_', _l('date_expired')) ?>",
        },
    },
}); 
    	
</script>
