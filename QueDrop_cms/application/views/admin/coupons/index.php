<!-- Page header -->
<div class="page-header page-header-default">
    <div class="page-header-content">
        <div class="page-title">
            <h4>
                <span class="text-semibold"><?php _el('coupons'); ?></span>
            </h4>
        </div>
    </div>
    <div class="breadcrumb-line">
        <ul class="breadcrumb">
            <li>
                <a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
            </li>
            <li class="active"><?php _el('coupons'); ?></li>
        </ul>
    </div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
    <!-- Panel -->
    <div class="panel panel-flat">
        <?php if (has_permissions('coupons','create')) { ?>
        <!-- Panel heading -->
        <div class="panel-heading">
            <?php  if ( has_permissions('coupons','create') || has_permissions('coupons','Delete') ) { ?>
            <a href="<?php echo base_url('admin/coupons/add'); ?>" class="btn btn-primary"><?php _el('add_new'); ?><i class="icon-plus-circle2 position-right"></i></a>  
            <?php } ?>
            <?php if (has_permissions('coupons','Delete')) { ?>
            <a href="javascript:delete_selected();" class="btn btn-danger" id="delete_selected"><?php _el('delete_selected'); ?><i class=" icon-trash position-right"></i></a>
            <?php } ?>
        </div>
        <!-- /Panel heading -->
        <?php } ?>
        
        <!-- Listing table -->
        <div class="panel-body table-responsive">
            <table id="users_table" class="table table-bordered table-striped">
                <thead>
                    <tr>
                        <?php if (has_permissions('coupons','delete')) { ?>
                        <th width="2%">
                            <input type="checkbox" name="select_all" id="select_all" class="styled" onclick="select_all(this);" >
                        </th>
                        <?php } ?>
                        <th width="30%"><?php _el('coupon_code'); ?></a></th>
                        <th width="30%"><?php _el('coupon_description'); ?></th>
                        <th width="30%"><?php _el('max_usage_per_user'); ?></th>
                        <th width="8%" class="text-center"><?php _el('status'); ?></th>
                        <?php if (has_permissions('coupons','edit') || has_permissions('coupons','delete')) { ?>
                        <th width="8%" class="text-center"><?php _el('actions'); ?></th>
                        <?php } ?>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($coupons as $key => $coupons) { ?>
                    <tr>
                        <?php if (has_permissions('coupons','delete')){
                        ?>
                        <td>
                            <input type="checkbox" class="checkbox styled"  name="delete"  id="<?php if ($coupons['id'] != get_loggedin_info('user_id')) {  echo $coupons['id']; }?>">
                        </td>
                        <?php } ?>

                        <td>
                            <?php echo $coupons['coupon_code']; ?>
                        </td>
                        <td>
                            <?php echo ucfirst($coupons['coupon_description']); ?>
                        </td>
                        <td>
                        <?php echo $coupons['max_usage_per_user']; ?>
                        </td>
                        <td class="text-center switchery-sm">
                            <input type="checkbox" onchange="change_status(this);" class="switchery"  id="<?php echo $coupons['id']; ?>" <?php if ($coupons['is_active'] == 1) { echo "checked"; } ?> >
                        </td>

                        <?php if (has_permissions('coupons','edit') || has_permissions('coupons','delete')) { ?>
                        <td class="text-center">
                            <?php  if (has_permissions('coupons', 'edit')) { ?>
                            <a data-popup="tooltip" data-placement="top"  title="<?php _el('edit') ?>" href="<?php echo site_url('admin/coupons/edit/').$coupons['id']; ?>" id="<?php echo $coupons['id']; ?>" class="text-info"><i class="icon-pencil7"></i></a>
                            <?php } ?>
                            <?php if (has_permissions('coupons', 'delete')) { ?>
                            <a data-popup="tooltip" data-placement="top"  title="<?php _el('delete') ?>" href="javascript:delete_record(<?php echo $coupons['id']; ?>);" class="text-danger delete" id="<?php echo $coupons['id']; ?>"><i class=" icon-trash"></i></a>
                            <?php } ?>
                        </td>
                        <?php } ?>
                    </tr>
                    <?php } ?>
                </tbody>
            </table>           
        </div>
        <!-- /Listing table -->
    </div>
    <!-- /Panel -->
</div>
<!-- /Content area -->

<script type="text/javascript">
$(function() {

    $('#users_table').DataTable({
        buttons: {
            dom: {
            button: {
                className: 'btn btn-default'
            }
            },
            buttons: [
            'copyHtml5',                
            'csvHtml5',
            'pdfHtml5'
            ]
        },
        'columnDefs': [ {
        'targets': [0,2,3,4], /* column index */
        'orderable': false, /* disable sorting */
        }],
         
    });

    //add class to style style datatable select box
    $('div.dataTables_length select').addClass('datatable-select');
 });


var BASE_URL = "<?php echo base_url(); ?>";

/**
 * Change status when clicked on the status switch
 *
 * @param {obj}  obj  The object
 */
function change_status(obj)
{
    var checked = 0;

    if(obj.checked) 
    { 
        checked = 1;
    }  

    $.ajax({
        url:BASE_URL+'admin/coupons/update_status',
        type: 'POST',
        data: {
            user_id: obj.id,
            is_active:checked
        },
        success: function(msg) 
        {
            if (msg=='true')
            {                           
                jGrowlAlert("<?php _el('_activated', _l('coupons')); ?>", 'success');
            }
            else
            {                  
                jGrowlAlert("<?php _el('_deactivated', _l('coupons')); ?>", 'success');
            }
        }
    }); 
}

/**
 * Deletes a single record when clicked on delete icon
 *
 * @param {int}  id  The identifier
 */
function delete_record(id) 
{ 
    swal({
        title: "<?php _el('single_deletion_alert'); ?>",
        text: "<?php _el('single_recovery_alert'); ?>",
        type: "warning", 
        showCancelButton: true, 
        cancelButtonText:"<?php _el('no_cancel_it'); ?>",
        confirmButtonText: "<?php _el('yes_i_am_sure'); ?>",  
    },
    function()
    {
        $.ajax({
            url:BASE_URL+'admin/coupons/delete',
            type: 'POST',
            data: {
                user_id:id
            },
            success: function(msg)
            {
                if (msg=="true")
                {                        
                    swal({
                        title: "<?php _el('_deleted_successfully', _l('coupons')); ?>",
                        type: "success",
                    });
                    $("#"+id).closest("tr").remove();
                }
                else
                {
                    swal({
                        title: "<?php _el('access_denied', _l('coupons')); ?>",                    
                        type: "error",                            
                    });
                }  
            }
        });
    });
}

/**
 * Deletes all the selected records when clicked on DELETE SELECTED button
 */
function delete_selected() 
{ 
    var user_ids = [];

    $(".checkbox:checked").each(function()
    {
        var id = $(this).attr('id');
        user_ids.push(id);
    });
    if (user_ids == '')
    {
        jGrowlAlert("<?php _el('select_before_delete_alert', _l('coupons')) ?>", 'danger');
        preventDefault();
    }
    swal({
        title: "<?php _el('multiple_deletion_alert'); ?>",
        text: "<?php _el('multiple_recovery_alert'); ?>",
        type: "warning", 
        showCancelButton: true, 
        cancelButtonText:"<?php _el('no_cancel_it'); ?>",
        confirmButtonText: "<?php _el('yes_i_am_sure'); ?>",       
    },
    function()
    {
        $.ajax({
            url:BASE_URL+'admin/coupons/delete_selected',
            type: 'POST',
            data: {
              ids:user_ids
            },
            success: function(msg)
            {
                if (msg=="true")
                {
                    swal({
                        title: "<?php _el('_deleted_successfully', _l('coupons')); ?>",
                        type: "success",
                    });
                    $(user_ids).each(function(index, element) 
                    {
                        $("#"+element).closest("tr").remove();
                    });
                }
                else
                {
                    swal({
                        title: "<?php _el('access_denied', _l('coupons')); ?>",                    
                        type: "error",                             
                    });
                }
            }
        });
    });
}

</script>
