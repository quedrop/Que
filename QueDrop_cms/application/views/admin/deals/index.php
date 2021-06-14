<!-- Page header -->
<div class="page-header page-header-default">
    <div class="page-header-content">
        <div class="page-title">
            <h4>
                <span class="text-semibold"><?php _el('deals'); ?></span>
            </h4>
        </div>
    </div>
    <div class="breadcrumb-line">
        <ul class="breadcrumb">
            <li>
                <a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
            </li>
            <li class="active"><?php _el('deals'); ?></li>
        </ul>
    </div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
    <!-- Panel -->
    <div class="panel panel-flat">
        <?php if (has_permissions('deals','create')) { ?>
        <!-- Panel heading -->
        <div class="panel-heading">
            <?php  if ( has_permissions('deals','create') || has_permissions('deals','Delete') ) { ?>
            <a href="<?php echo base_url('admin/deals/add'); ?>" class="btn btn-primary"><?php _el('add_new'); ?><i class="icon-plus-circle2 position-right"></i></a>  
            <?php } ?>
            <?php if (has_permissions('deals','Delete')) { ?>
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
                        <?php if (has_permissions('deals','delete')) { ?>
                        <th width="2%">
                            <input type="checkbox" name="select_all" id="select_all" class="styled" onclick="select_all(this);" >
                        </th>
                        <?php } ?>
                        <th width="30%"><?php _el('deal_name'); ?></a></th>
                        <th width="30%"><?php _el('deal_description'); ?></th>
                        <th width="30%"><?php _el('deal_value'); ?></th>
                        <th width="30%"><?php _el('date_created'); ?></th>
                        <th width="30%"><?php _el('date_expired'); ?></th>
                        <th width="8%" class="text-center"><?php _el('status'); ?></th>
                        <?php if (has_permissions('deals','edit') || has_permissions('deals','delete')) { ?>
                        <th width="8%" class="text-center"><?php _el('actions'); ?></th>
                        <?php } ?>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($deals as $key => $deals) { ?>
                    <tr>
                        <?php if (has_permissions('deals','delete')){
                        ?>
                        <td>
                            <input type="checkbox" class="checkbox styled"  name="delete"  id="<?php if ($deals['id'] != get_loggedin_info('user_id')) {  echo $deals['id']; }?>">
                        </td>
                        <?php } ?>

                        <td>
                            <?php echo ucfirst($deals['deal_name']); ?>
                        </td>
                        <td>
                            <?php echo ucfirst($deals['deal_description']); ?>
                        </td>
                        <td>
                        <?php echo "$".$deals['deal_value']; ?>
                        </td>
                        <td>
                            <?php echo $deals['date_created'] ?>
                        </td>
                        <td>
                            <?php echo $deals['date_expired'] ?>
                        </td>
                       
                        <td class="text-center switchery-sm">
                            <input type="checkbox" onchange="change_status(this);" class="switchery"  id="<?php echo $deals['id']; ?>" <?php if ($deals['is_active'] == 1) { echo "checked"; } ?> >
                        </td>

                        <?php if (has_permissions('deals','edit') || has_permissions('deals','delete')) { ?>
                        <td class="text-center">
                            <?php  if (has_permissions('deals', 'edit')) { ?>
                            <a data-popup="tooltip" data-placement="top"  title="<?php _el('edit') ?>" href="<?php echo site_url('admin/deals/edit/').$deals['id']; ?>" id="<?php echo $deals['id']; ?>" class="text-info"><i class="icon-pencil7"></i></a>
                            <?php } ?>
                            <?php if (has_permissions('deals', 'delete')) { ?>
                            <a data-popup="tooltip" data-placement="top"  title="<?php _el('delete') ?>" href="javascript:delete_record(<?php echo $deals['id']; ?>);" class="text-danger delete" id="<?php echo $deals['id']; ?>"><i class=" icon-trash"></i></a>
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
        url:BASE_URL+'admin/deals/update_status',
        type: 'POST',
        data: {
            user_id: obj.id,
            is_active:checked
        },
        success: function(msg) 
        {
            if (msg=='true')
            {                           
                jGrowlAlert("<?php _el('_activated', _l('deals')); ?>", 'success');
            }
            else
            {                  
                jGrowlAlert("<?php _el('_deactivated', _l('deals')); ?>", 'success');
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
            url:BASE_URL+'admin/deals/delete',
            type: 'POST',
            data: {
                user_id:id
            },
            success: function(msg)
            {
                if (msg=="true")
                {                        
                    swal({
                        title: "<?php _el('_deleted_successfully', _l('deals')); ?>",
                        type: "success",
                    });
                    $("#"+id).closest("tr").remove();
                }
                else
                {
                    swal({
                        title: "<?php _el('access_denied', _l('deals')); ?>",                    
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
        jGrowlAlert("<?php _el('select_before_delete_alert', _l('deals')) ?>", 'danger');
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
            url:BASE_URL+'admin/deals/delete_selected',
            type: 'POST',
            data: {
              ids:user_ids
            },
            success: function(msg)
            {
                if (msg=="true")
                {
                    swal({
                        title: "<?php _el('_deleted_successfully', _l('deals')); ?>",
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
                        title: "<?php _el('access_denied', _l('deals')); ?>",                    
                        type: "error",                             
                    });
                }
            }
        });
    });
}

</script>
